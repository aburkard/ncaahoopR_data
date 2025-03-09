### Install Latest Version of Package
devtools::install_github('lbenz730/ncaahoopR')

library(ncaahoopR)
library(readr)
library(dplyr)
library(lubridate)

# Convert the input data into a proper dataframe
game_list <- list(
  # Formatted as [date, team, game_id]
  c("2025-01-08", "UMKC", "401706507"),
  c("2024-11-23", "UMKC", "401722102"),
  c("2024-11-18", "UMKC", "401727096"),
  c("2024-11-16", "UMKC", "401715451"),
  c("2025-02-27", "UMKC", "401706564"),
  c("2025-03-06", "UMKC", "401744196"),
  c("2024-12-04", "UMKC", "401720564"),
  c("2024-12-10", "UMKC", "401725205"),
  c("2025-02-19", "UMKC", "401706555"),
  c("2025-01-30", "UMKC", "401706533"),
  c("2025-01-15", "IU Indy", "401714467"),
  c("2024-11-08", "IU Indy", "401715622"),
  c("2025-01-22", "IU Indy", "401714477"),
  c("2024-11-18", "IU Indy", "401706956"),
  c("2024-12-04", "IU Indy", "401714396"),
  c("2025-02-05", "IU Indy", "401714436"),
  c("2025-02-12", "IU Indy", "401714447"),
  c("2024-11-12", "IU Indy", "401727501"),
  c("2024-11-04", "IU Indy", "401727499"),
  c("2024-12-05", "MD-E Shore", "401720471"),
  c("2025-03-01", "MD-E Shore", "401723741"),
  c("2025-02-03", "MD-E Shore", "401723691"),
  c("2024-11-25", "MD-E Shore", "401723726"),
  c("2025-02-17", "MD-E Shore", "401723732"),
  c("2024-12-28", "MD-E Shore", "401707874"),
  c("2024-11-27", "MD-E Shore", "401723727"),
  c("2025-02-01", "MD-E Shore", "401723731"),
  c("2024-11-20", "MD-E Shore", "401723725"),
  c("2024-11-07", "MD-E Shore", "401721668"),
  c("2024-11-15", "MD-E Shore", "401723724"),
  c("2024-11-18", "MD-E Shore", "401723734"),
  c("2024-12-14", "MD-E Shore", "401723735"),
  c("2024-11-04", "MD-E Shore", "401723723"),
  c("2025-02-10", "MD-E Shore", "401723737"),
  c("2024-12-16", "MD-E Shore", "401723736"),
  c("2025-03-06", "MD-E Shore", "401723722"),
  c("2025-01-25", "MD-E Shore", "401723710"),
  c("2025-02-15", "MD-E Shore", "401723738"),
  c("2025-03-03", "MD-E Shore", "401723701"),
  c("2025-01-04", "MD-E Shore", "401723728"),
  c("2024-12-08", "MD-E Shore", "401722026"),
  c("2024-11-23", "MD-E Shore", "401707851"),
  c("2024-11-30", "MD-E Shore", "401715612"),
  c("2024-11-08", "Texas A&M-Commerce", "401715356"),
  c("2025-02-03", "Texas A&M-Commerce", "401720761"),
  c("2024-12-05", "Texas A&M-CC", "401720670"),
  c("2025-02-03", "Texas A&M-CC", "401720761"),
  c("2024-11-21", "Texas A&M-CC", "401720749"),
  c("2025-01-25", "Texas A&M-CC", "401720759"),
  c("2024-12-21", "Texas A&M-CC", "401706953"),
  c("2024-12-29", "Texas A&M-CC", "401720756"),
  c("2024-12-14", "Texas A&M-CC", "401720754"),
  c("2024-11-23", "Texas A&M-CC", "401720750"),
  c("2024-11-26", "Texas A&M-CC", "401720751"),
  c("2025-03-03", "Texas A&M-CC", "401720745"),
  c("2024-11-12", "Texas A&M-CC", "401720747"),
  c("2025-01-27", "Texas A&M-CC", "401720720"),
  c("2025-01-06", "Texas A&M-CC", "401720737"),
  c("2025-02-10", "Texas A&M-CC", "401720680"),
  c("2025-03-01", "Texas A&M-CC", "401716068"),
  c("2022-11-09", "UMKC", "401485461"),
  c("2022-12-31", "UMKC", "401470189"),
  c("2022-11-11", "UMKC", "401483338"),
  c("2022-11-14", "UMKC", "401489583"),
  c("2022-12-03", "UMKC", "401489586"),
  c("2022-12-06", "UMKC", "401483295"),
  c("2022-12-10", "UMKC", "401489587"),
  c("2022-11-21", "UMKC", "401486677"),
  c("2023-01-28", "UMKC", "401470224"),
  c("2022-12-29", "UMKC", "401470184"),
  c("2023-01-26", "UMKC", "401470220"),
  c("2023-03-03", "UMKC", "401514362"),
  c("2023-02-23", "Texas A&M-CC", "401485449"),
  c("2023-03-01", "Texas A&M-CC", "401485460"),
  c("2023-01-19", "Texas A&M-CC", "401485398"),
  c("2023-01-28", "Texas A&M-CC", "401485414"),
  c("2022-12-07", "Texas A&M-CC", "401489639"),
  c("2023-01-26", "Texas A&M-CC", "401485410"),
  c("2023-03-07", "Texas A&M-CC", "401524234"),
  c("2023-03-16", "Texas A&M-CC", "401522123"),
  c("2023-01-12", "Texas A&M-CC", "401485391"),
  c("2023-02-11", "Texas A&M-CC", "401485435"),
  c("2023-01-14", "Texas A&M-CC", "401485395"),
  c("2023-02-02", "Texas A&M-CC", "401485418"),
  c("2022-12-16", "Texas A&M-CC", "401489641"),
  c("2022-11-11", "Texas A&M-CC", "401487297")
)

games_df <- do.call(rbind, game_list) %>% 
  as.data.frame() %>% 
  setNames(c("date", "team", "game_id"))

games_df$date <- as.Date(games_df$date)

# Process each game
total_games <- nrow(games_df)
for (i in 1:total_games) {
  # Get the game information
  current_date <- games_df$date[i]
  current_team <- games_df$team[i]
  current_game_id <- games_df$game_id[i]
  
  # Determine the season (e.g., 2024-25) from the date
  year <- year(current_date)
  month <- month(current_date)
  
  # If date is between August-December, it's the first part of the season
  # Otherwise it's the second part
  season_year <- if (month >= 8 && month <= 12) year else year - 1
  season <- paste0(season_year, "-", substr(season_year + 1, 3, 4))
  
  cat(sprintf("Processing game %d of %d: %s %s (Season: %s)\n", 
              i, total_games, current_team, current_game_id, season))
  
  # Ensure directories exist
  if (!dir.exists(season)) {
    dir.create(season)
  }
  if (!dir.exists(paste0(season, '/box_scores/'))) {
    dir.create(paste0(season, '/box_scores/'))
  }
  if (!dir.exists(paste0(season, '/box_scores/', gsub(" ", "_", current_team)))) {
    dir.create(paste0(season, '/box_scores/', gsub(" ", "_", current_team)))
  }
  
  # Try to get the box score
  box <- try(get_boxscore(current_game_id))
  
  if (is.null(box)) {
    cat("  Box score is NULL, skipping\n")
    next
  } else if (class(box)[1] == 'try-error') {
    cat("  Error getting box score, skipping\n")
    next
  }
  
  # Determine the correct team name in the box score
  box_team <- case_when(
    current_team == "UConn" ~ current_team, 
    current_team == "UMKC" ~ "Kansas City",
    current_team == "IU Indy" ~ "IU Indianapolis",
    current_team == "IUPUI" ~ "IU Indianapolis",
    current_team == "MD-E Shore" ~ "Maryland Eastern Shore",
    current_team == "Texas A&M-Commerce" ~ "East Texas A&M",
    current_team == "Texas A&M-CC" ~ "Texas A&M-Corpus Christi",
    current_team == "Cal Baptist" ~ "California Baptist",
    TRUE ~ dict$ESPN_PBP[dict$ESPN == current_team]
  )
  
  # If team name not found, try to find the best match
  if (!(box_team %in% names(box))) {
    teams <- names(box)
    substring_ix <- grepl(current_team, teams)
    if (sum(substring_ix) == 1) {
      box_team <- teams[substring_ix] 
    } else {
      # First try Jaro-Winkler distance - best for team names
      distances <- stringdist::stringdist(teams, current_team, method = "jw")
      best_match <- teams[which.min(distances)]
      min_dist <- min(distances)
      
      # If the match is good enough (threshold may need tuning)
      if (min_dist < 0.3) {
        box_team <- best_match
      } else {
        # Fall back to cosine similarity for more distant matches
        distances <- stringdist::stringdist(teams, current_team, method = "cosine", q = 2)
        box_team <- teams[which.min(distances)]
      }
    }
  }
  
  # Save the box score if we have a valid team name
  if (box_team %in% names(box) && !is.na(box_team)) {
    file_path <- paste0(season, "/box_scores/", gsub(" ", "_", current_team), "/", current_game_id, ".csv")
    
    df <- as.data.frame(box[[box_team]])
    df$date <- current_date
    df$game_id <- current_game_id
    
    # We don't have opponent and location info without the schedule, so mark them as NA
    df$opponent <- NA
    df$location <- NA
    
    write_csv(df, file_path)
    cat("  Successfully saved box score to", file_path, "\n")
  } else {
    cat("  Could not find team", current_team, "in box score\n")
  }
}

cat("\nFinished processing all", total_games, "games\n")