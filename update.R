### Install Latest Version of Package
devtools::install_github('lbenz730/ncaahoopR')

library(ncaahoopR)
library(readr)

# Season year variables
season_year <- 2023  # First year of the season (e.g., 2024 for 2024-25 season)
season <- paste0(season_year, "-", substr(season_year + 1, 3, 4))  # Creates "2024-25" format

# Calculate November 1st of the season year
season_start_date <- as.Date(paste0(season_year, "-11-01"))

fresh_scrape <- F ### rescrape old data from current season?
skip_pbp_logs <- T ### skip scraping play-by-play logs
skip_master_schedule <- T ### skip creating master schedule
skip_rosters <- T ### skip scraping rosters
skip_schedules <- T ### skip scraping schedules
n <- nrow(ids)
if(!dir.exists(paste0(season, '/rosters/'))) {
  dir.create(season) 
  dir.create(paste0(season, '/rosters/')) 
  dir.create(paste0(season, '/pbp_logs/')) 
  dir.create(paste0(season, '/schedules/')) 
  dir.create(paste0(season, '/box_scores/')) 
}

### Schedules + Rosters
for(i in 1:n) {
  cat("Scraping Data for Team", i, "of", n, paste0("(", ids$team[i], ")"), "\n")
  
  if(!skip_schedules) {
    schedule <- try(as.data.frame(get_schedule(ids$team[i], season)))
    if(class(schedule) != 'try-error') {
      write_csv(schedule, paste0(season, "/schedules/", gsub(" ", "_", ids$team[i]), "_schedule.csv"))
    }
  }
  
  if(!skip_rosters) {
    roster <- try(as.data.frame(get_roster(ids$team[i], season)))
    if(class(roster) != 'try-error') {
      write_csv(roster, paste0(season, "/rosters/", gsub(" ", "_", ids$team[i]), "_roster.csv"))
    }
  }
}

### Pull Games
if(!skip_pbp_logs) {
  date <- max(season_start_date, as.Date(dir(paste0(season, '/pbp_logs/'))) %>% max(na.rm = T))
  if(fresh_scrape) {
    date <- season_start_date
  }
  while(date <= Sys.Date()) {
    print(date)
    schedule <- try(get_master_schedule(date))
    if(class(schedule) != 'try-error' & !is.null(schedule)) {
      if(!dir.exists(paste(season, "pbp_logs", date, sep = "/"))) {
        dir.create(paste(season, "pbp_logs", date, sep = "/")) 
      }
      write_csv(schedule, paste(season, "pbp_logs", date, "schedule.csv", sep = "/"))
      
      n <- nrow(schedule)
      for(i in 1:n) {
        if(!file.exists(paste(season, "pbp_logs", date, paste0(schedule$game_id[i], ".csv"), sep = "/")) | fresh_scrape) {
          print(paste("Getting Game", i, "of", n, "on", date))
          x <- try(get_pbp_game(schedule$game_id[i]))
          if(!is.null(x) & class(x) != "try-error") {
            write_csv(x, paste(season, "pbp_logs", date, paste0(schedule$game_id[i], ".csv"), sep = "/"))
          }
        }
      }
    }
    date <- date + 1
  }
}

### Update Master Schedule
if(!skip_master_schedule) {
date <- season_start_date
master_schedule <- NULL
while(date <= Sys.Date()) {
  print(date)
  schedule <- try(read_csv(paste(season, "pbp_logs", date, "schedule.csv", sep = "/")) %>%
                    mutate("date" = date))
  if(class(schedule)[1] != "try-error") {
    write_csv(schedule, paste(season, "pbp_logs", date, "schedule.csv", sep = "/"))
    master_schedule <- bind_rows(master_schedule, schedule)
  }
  
  date <- date + 1
  }
  write_csv(master_schedule, paste0(season, "/pbp_logs/schedule.csv"))
}

### Box Scores
schedules <- dir(paste(season, "schedules", sep = "/"), full.names = T)
schedules_clean <- dir(paste(season, "schedules", sep = "/"), full.names = F)
n <- length(schedules)
for(i in 1:n) {
  
  ### Read in Schedule
  s <- read_csv(schedules[i], col_types = cols())
  s <- filter(s, date <= Sys.Date())
  n1 <- nrow(s)
  ### Try to Scrape PBP
  for(k in 1:n1) {
    cat("Scraping Game", k, "of", n1, "for Team", i, "of", n, "\n")
    team <- gsub("_", " ", gsub("_schedule.csv", "", schedules_clean[i]))
    file <- paste(season, "box_scores", gsub(" ", "_", team), paste0(s$game_id[k], ".csv"), sep = "/")
    if(!file.exists(file)) {
      box <- try(get_boxscore(s$game_id[k]))
      
      if(is.null(box)) {
        next
      } else if(class(box) == 'try-error') {
        next
      }
      
      box_team <- case_when(team == "UConn" ~ team, 
                            team == "UMKC" ~ "Kansas City",
                            team == "IU Indy" ~ "IU Indianapolis",
                            team == "IUPUI" ~ "IU Indianapolis",
                            team == "MD-E Shore" ~ "Maryland Eastern Shore",
                            team == "Texas A&M-Commerce" ~ "East Texas A&M",
                            team == "Texas A&M-CC" ~ "Texas A&M-Corpus Christi",
                            team == "Cal Baptist" ~ "California Baptist",
                            T ~ dict$ESPN_PBP[dict$ESPN == team])
      
      if(!(box_team %in% names(box))) {
        teams <- names(box)
        substring_ix <- grepl(team, teams)
        if(sum(substring_ix) == 1) {
          box_team <- teams[substring_ix] 
        } else {
          # First try Jaro-Winkler distance - best for team names
          distances <- stringdist::stringdist(teams, team, method = "jw")
          best_match <- teams[which.min(distances)]
          min_dist <- min(distances)
          
          # If the match is good enough (threshold may need tuning)
          if(min_dist < 0.3) {
            box_team <- best_match
          } else {
            # Fall back to cosine similarity for more distant matches
            distances <- stringdist::stringdist(teams, team, method = "cosine", q = 2)
            box_team <- teams[which.min(distances)]
          }
        }
      }
      
      
      if(class(box) != "try-error" & box_team %in% names(box) & !is.na(box_team)) {
        ### Create Date Directory if Doesn't Exist
        if(!dir.exists(paste(season, "box_scores", sep = "/"))) {
          dir.create(paste(season, "box_scores", sep = "/")) 
        }
        if(!dir.exists(paste(season, "box_scores", gsub(" ", "_", team), sep = "/"))) {
          dir.create(paste(season, "box_scores", gsub(" ", "_", team), sep = "/"))
        }
        df <- as.data.frame(box[[box_team]])
        df$date <- s$date[k]
        df$opponent <- s$opponent[k]
        df$location <- s$location[k]
        write_csv(df, file)
      } 
    }
  }
}