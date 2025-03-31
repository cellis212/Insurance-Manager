# validation.R
# Helper functions for validating and sanitizing game state

#' Validates a game state object and supplies default values where needed
#'
#' @param state The game state object to validate
#' @return A validated game state object with defaults applied where needed
validate_game_state <- function(state) {
  if (is.null(state)) {
    state <- list()
  }
  
  # Ensure market_conditions exists
  if (is.null(state$market_conditions)) {
    state$market_conditions <- list()
  }
  
  # Apply default market condition if missing
  if (is.null(state$market_conditions$market_condition)) {
    state$market_conditions$market_condition <- 0.5  # Neutral market condition
  }
  
  # Ensure parameters exists
  if (is.null(state$parameters)) {
    state$parameters <- list()
  }
  
  # Ensure regulator_strictness exists
  if (is.null(state$parameters$regulator_strictness)) {
    state$parameters$regulator_strictness <- list()
  }
  
  # Apply default regulator strictness for each region if missing
  regions <- c("Iowa", "Georgia", "Florida")
  for (region in regions) {
    if (is.null(state$parameters$regulator_strictness[[region]])) {
      # Default strictness values per region
      defaults <- list(
        Iowa = 0.6,
        Georgia = 0.7,
        Florida = 0.8
      )
      state$parameters$regulator_strictness[[region]] <- defaults[[region]]
    }
  }
  
  # Ensure catastrophe_probability exists
  if (is.null(state$parameters$catastrophe_probability)) {
    state$parameters$catastrophe_probability <- list()
  }
  
  # Apply default catastrophe probabilities for each region if missing
  for (region in regions) {
    if (is.null(state$parameters$catastrophe_probability[[region]])) {
      # Default catastrophe probabilities per region
      defaults <- list(
        Iowa = 0.05,
        Georgia = 0.08,
        Florida = 0.15
      )
      state$parameters$catastrophe_probability[[region]] <- defaults[[region]]
    }
  }
  
  # Ensure events list exists
  if (is.null(state$events)) {
    state$events <- list()
  }
  
  # Ensure results exists
  if (is.null(state$results)) {
    state$results <- list()
  }
  
  return(state)
}

#' Calculates the combined ratio for an insurance product
#'
#' @param premiums Total premiums collected
#' @param claims Total claims paid
#' @param expenses Total expenses incurred
#' @return Combined ratio as a decimal (1.0 = 100%)
calculate_combined_ratio <- function(premiums, claims, expenses) {
  if (premiums <= 0) {
    return(NA_real_)
  }
  
  return((claims + expenses) / premiums)
}

#' Validates player decision inputs and applies reasonable constraints
#'
#' @param decisions A list of player decisions
#' @return Validated and constrained decisions
validate_player_decisions <- function(decisions) {
  if (is.null(decisions)) {
    return(list())
  }
  
  # Validate premium adjustments (keep between 0.5 and 2.0)
  if (!is.null(decisions$premium_adjustments)) {
    for (line in names(decisions$premium_adjustments)) {
      for (region in names(decisions$premium_adjustments[[line]])) {
        adjustment <- decisions$premium_adjustments[[line]][[region]]
        decisions$premium_adjustments[[line]][[region]] <- max(0.5, min(2.0, adjustment))
      }
    }
  }
  
  # Validate investment allocations (ensure they sum to 1.0)
  if (!is.null(decisions$investments)) {
    total <- sum(unlist(decisions$investments))
    if (total > 0) {
      for (asset in names(decisions$investments)) {
        decisions$investments[[asset]] <- decisions$investments[[asset]] / total
      }
    } else {
      # Default to equal allocation if total is 0
      assets <- names(decisions$investments)
      equal_share <- 1 / length(assets)
      for (asset in assets) {
        decisions$investments[[asset]] <- equal_share
      }
    }
  }
  
  return(decisions)
} 