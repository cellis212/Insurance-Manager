# Insurance Simulation Game - Data Operations
# This file contains functions for saving and loading player decisions and game state

library(jsonlite)

# Constants
DATA_DIR <- "data"

#' Ensure data directory exists
#' @return TRUE if directory exists or was created, FALSE otherwise
ensure_data_dir <- function() {
  if (!dir.exists(DATA_DIR)) {
    dir.create(DATA_DIR, recursive = TRUE)
  }
  return(dir.exists(DATA_DIR))
}

#' Generate a player ID based on their profile
#' 
#' @param username Player's username
#' @param major Player's chosen secondary major
#' @param gradSchool Player's chosen graduate school
#' @param university Player's chosen university
#' @return A unique identifier for the player
generate_player_id <- function(username, major, gradSchool, university) {
  # Creates a deterministic hash-like ID based on player inputs
  id_components <- paste(username, major, gradSchool, university, sep = "_")
  # Using a simple encoding to create a unique ID
  encoded_id <- digest::digest(id_components, algo = "md5")
  return(encoded_id)
}

#' Save player profile to file
#' 
#' @param username Player's username
#' @param profile List with player profile data
#' @return TRUE if successful, FALSE otherwise
save_player_profile <- function(username, profile) {
  ensure_data_dir()
  
  # Generate player ID
  player_id <- generate_player_id(
    username, 
    profile$major, 
    profile$gradSchool, 
    profile$university
  )
  
  # Add player ID to profile
  profile$player_id <- player_id
  
  # Create filename based on player ID
  filename <- file.path(DATA_DIR, paste0("profile_", player_id, ".json"))
  
  # Save profile as JSON
  result <- tryCatch({
    write_json(profile, filename, pretty = TRUE)
    TRUE
  }, error = function(e) {
    message("Error saving player profile: ", e$message)
    FALSE
  })
  
  return(result)
}

#' Load player profile from file
#' 
#' @param player_id Player's unique identifier
#' @return Player profile as a list, or NULL if not found
load_player_profile <- function(player_id) {
  filename <- file.path(DATA_DIR, paste0("profile_", player_id, ".json"))
  
  if (!file.exists(filename)) {
    return(NULL)
  }
  
  profile <- tryCatch({
    read_json(filename, simplifyVector = TRUE)
  }, error = function(e) {
    message("Error loading player profile: ", e$message)
    NULL
  })
  
  return(profile)
}

#' Save player decision to file
#' 
#' @param player_id Player's unique identifier
#' @param decision List with player decisions
#' @param turn Current turn/round number
#' @return TRUE if successful, FALSE otherwise
save_player_decision <- function(player_id, decision, turn) {
  ensure_data_dir()
  
  # Add metadata to decision
  decision$player_id <- player_id
  decision$turn <- turn
  decision$timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  
  # Create filename based on player ID and turn
  filename <- file.path(DATA_DIR, paste0("decision_", player_id, "_turn_", turn, ".json"))
  
  # Save decision as JSON
  result <- tryCatch({
    write_json(decision, filename, pretty = TRUE)
    TRUE
  }, error = function(e) {
    message("Error saving player decision: ", e$message)
    FALSE
  })
  
  return(result)
}

#' Load player decision from file
#' 
#' @param player_id Player's unique identifier
#' @param turn Turn/round number
#' @return Player decision as a list, or NULL if not found
load_player_decision <- function(player_id, turn) {
  filename <- file.path(DATA_DIR, paste0("decision_", player_id, "_turn_", turn, ".json"))
  
  if (!file.exists(filename)) {
    return(NULL)
  }
  
  decision <- tryCatch({
    read_json(filename, simplifyVector = TRUE)
  }, error = function(e) {
    message("Error loading player decision: ", e$message)
    NULL
  })
  
  return(decision)
}

#' List all player decisions for a specific turn
#' 
#' @param turn Turn/round number
#' @return List of player decision file paths
list_player_decisions <- function(turn) {
  ensure_data_dir()
  
  # Pattern to match decision files for the given turn
  pattern <- paste0("decision_.*_turn_", turn, "\\.json$")
  
  # List files matching the pattern
  files <- list.files(
    path = DATA_DIR,
    pattern = pattern,
    full.names = TRUE
  )
  
  return(files)
}

#' Aggregate all player decisions for a turn
#' 
#' @param turn Turn/round number
#' @return List of all player decisions
aggregate_player_decisions <- function(turn) {
  decision_files <- list_player_decisions(turn)
  
  if (length(decision_files) == 0) {
    message("No decisions found for turn ", turn)
    return(list())
  }
  
  # Initialize empty list for decisions
  all_decisions <- list()
  
  # Load each decision file and add to the list
  for (file in decision_files) {
    decision <- tryCatch({
      read_json(file, simplifyVector = TRUE)
    }, error = function(e) {
      message("Error loading decision file ", file, ": ", e$message)
      NULL
    })
    
    if (!is.null(decision)) {
      all_decisions[[decision$player_id]] <- decision
    }
  }
  
  return(all_decisions)
}

#' Save game state to file
#' 
#' @param game_state List with game state data
#' @param turn Current turn/round number
#' @return TRUE if successful, FALSE otherwise
save_game_state <- function(game_state, turn) {
  ensure_data_dir()
  
  # Add metadata to game state
  game_state$turn <- turn
  game_state$timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  
  # Create filename
  filename <- file.path(DATA_DIR, paste0("game_state_turn_", turn, ".json"))
  
  # Save game state as JSON
  result <- tryCatch({
    write_json(game_state, filename, pretty = TRUE, auto_unbox = TRUE)
    TRUE
  }, error = function(e) {
    message("Error saving game state: ", e$message)
    FALSE
  })
  
  return(result)
}

#' Load game state from file
#' 
#' @param turn Turn/round number
#' @return Game state as a list, or NULL if not found
load_game_state <- function(turn) {
  filename <- file.path(DATA_DIR, paste0("game_state_turn_", turn, ".json"))
  
  if (!file.exists(filename)) {
    return(NULL)
  }
  
  game_state <- tryCatch({
    read_json(filename, simplifyVector = TRUE)
  }, error = function(e) {
    message("Error loading game state: ", e$message)
    NULL
  })
  
  return(game_state)
}

#' Get the latest turn number
#' 
#' @return The latest turn number, or 0 if no game states found
get_latest_turn <- function() {
  ensure_data_dir()
  
  # Pattern to match game state files
  pattern <- "game_state_turn_(\\d+)\\.json$"
  
  # List all game state files
  files <- list.files(
    path = DATA_DIR,
    pattern = pattern
  )
  
  if (length(files) == 0) {
    return(0)
  }
  
  # Extract turn numbers from filenames
  turn_numbers <- numeric(length(files))
  for (i in seq_along(files)) {
    match <- regexec(pattern, files[i])
    if (match[[1]][1] > 0) {
      turn_str <- substr(files[i], match[[1]][2], match[[1]][2] + attr(match[[1]], "match.length")[2] - 1)
      turn_numbers[i] <- as.numeric(turn_str)
    }
  }
  
  # Return the maximum turn number
  return(max(turn_numbers, na.rm = TRUE))
}

#' Create a default game state for a new game
#' 
#' @return A default game state list
create_default_game_state <- function() {
  # Create a default game state with market conditions and simulation parameters
  game_state <- list(
    turn = 0,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    market_conditions = list(
      # Default competitor premiums (100 = baseline)
      competitor_premiums = list(
        Home = list(
          Iowa = 100,
          Georgia = 102,
          Florida = 105
        ),
        Auto = list(
          Iowa = 100,
          Georgia = 101,
          Florida = 103
        ),
        Health = list(
          Iowa = 100,
          Georgia = 100,
          Florida = 102
        ),
        Life = list(
          Iowa = 100,
          Georgia = 99,
          Florida = 101
        ),
        Annuities = list(
          Iowa = 100,
          Georgia = 100,
          Florida = 102
        )
      ),
      # Default competitor utilities
      competitor_utilities = list(
        Home = list(
          Iowa = c(4.8, 4.7, 4.9),
          Georgia = c(4.3, 4.4, 4.5),
          Florida = c(5.2, 5.3, 5.4)
        ),
        Auto = list(
          Iowa = c(4.6, 4.5, 4.7),
          Georgia = c(5.0, 5.1, 4.9),
          Florida = c(4.7, 4.8, 4.6)
        ),
        Health = list(
          Iowa = c(5.1, 5.0, 5.2),
          Georgia = c(4.7, 4.8, 4.6),
          Florida = c(4.9, 5.0, 4.8)
        ),
        Life = list(
          Iowa = c(4.3, 4.4, 4.2),
          Georgia = c(4.5, 4.6, 4.4),
          Florida = c(4.4, 4.5, 4.3)
        ),
        Annuities = list(
          Iowa = c(4.0, 4.1, 3.9),
          Georgia = c(4.2, 4.3, 4.1),
          Florida = c(4.1, 4.2, 4.0)
        )
      ),
      # Market sizes (number of potential policies)
      market_sizes = list(
        Home = list(
          Iowa = 10000,
          Georgia = 20000,
          Florida = 30000
        ),
        Auto = list(
          Iowa = 15000,
          Georgia = 25000,
          Florida = 35000
        ),
        Health = list(
          Iowa = 12000,
          Georgia = 22000,
          Florida = 32000
        ),
        Life = list(
          Iowa = 8000,
          Georgia = 18000,
          Florida = 28000
        ),
        Annuities = list(
          Iowa = 5000,
          Georgia = 15000,
          Florida = 25000
        )
      ),
      # General market condition (-1 to 1, with 0 being neutral)
      market_condition = 0,
      # Outside option utility (not purchasing insurance)
      outside_option_utility = 1
    ),
    # Any global events that might affect the simulation
    events = list(),
    # Game parameters that can be adjusted by administrators
    parameters = list(
      regulator_strictness = list(
        Iowa = 0.7,    # Moderate regulation
        Georgia = 0.5, # Less strict
        Florida = 0.9  # Very strict
      ),
      catastrophe_probability = list(
        Iowa = 0.05,   # Low chance
        Georgia = 0.1, # Moderate chance
        Florida = 0.2  # High chance (hurricanes)
      )
    ),
    # Player results from previous turn (empty for new game)
    results = list()
  )
  
  return(game_state)
}

#' Initialize a new game
#' 
#' @return TRUE if successful, FALSE otherwise
initialize_new_game <- function() {
  ensure_data_dir()
  
  # Create default game state
  game_state <- create_default_game_state()
  
  # Save as turn 0
  result <- save_game_state(game_state, 0)
  
  return(result)
} 