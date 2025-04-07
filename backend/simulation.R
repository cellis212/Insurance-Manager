# Insurance Simulation Game - Simulation Logic
# This file contains the core simulation functions for the Insurance Manager application
# Following a BLP-style utility framework for demand and cost simulation

# Constants and configuration
INSURANCE_LINES <- c("Home", "Auto", "Health", "Life", "Annuities")
REGIONS <- c("Iowa", "Georgia", "Florida")

# Base utility parameters for different lines across regions
# These would be adjustable by administrators
base_utility_params <- list(
  Home = list(
    Iowa = list(base_attraction = 5.0, price_sensitivity = 0.08, competitor_effect = 0.2),
    Georgia = list(base_attraction = 4.5, price_sensitivity = 0.07, competitor_effect = 0.25),
    Florida = list(base_attraction = 5.5, price_sensitivity = 0.09, competitor_effect = 0.15)
  ),
  Auto = list(
    Iowa = list(base_attraction = 4.8, price_sensitivity = 0.06, competitor_effect = 0.3),
    Georgia = list(base_attraction = 5.2, price_sensitivity = 0.07, competitor_effect = 0.22),
    Florida = list(base_attraction = 4.9, price_sensitivity = 0.08, competitor_effect = 0.18)
  ),
  Health = list(
    Iowa = list(base_attraction = 5.3, price_sensitivity = 0.1, competitor_effect = 0.15),
    Georgia = list(base_attraction = 4.9, price_sensitivity = 0.09, competitor_effect = 0.2),
    Florida = list(base_attraction = 5.1, price_sensitivity = 0.11, competitor_effect = 0.17)
  ),
  Life = list(
    Iowa = list(base_attraction = 4.5, price_sensitivity = 0.04, competitor_effect = 0.25),
    Georgia = list(base_attraction = 4.7, price_sensitivity = 0.05, competitor_effect = 0.22),
    Florida = list(base_attraction = 4.6, price_sensitivity = 0.06, competitor_effect = 0.27)
  ),
  Annuities = list(
    Iowa = list(base_attraction = 4.2, price_sensitivity = 0.03, competitor_effect = 0.3),
    Georgia = list(base_attraction = 4.4, price_sensitivity = 0.04, competitor_effect = 0.25),
    Florida = list(base_attraction = 4.3, price_sensitivity = 0.05, competitor_effect = 0.28)
  )
)

# Base cost parameters
base_cost_params <- list(
  Home = list(
    Iowa = list(base_cost = 1000, loss_frequency = 0.05, severity_mean = 20000, admin_costs = 200),
    Georgia = list(base_cost = 1200, loss_frequency = 0.06, severity_mean = 22000, admin_costs = 220),
    Florida = list(base_cost = 1800, loss_frequency = 0.08, severity_mean = 25000, admin_costs = 250)
  ),
  Auto = list(
    Iowa = list(base_cost = 800, loss_frequency = 0.1, severity_mean = 8000, admin_costs = 150),
    Georgia = list(base_cost = 900, loss_frequency = 0.12, severity_mean = 8500, admin_costs = 170),
    Florida = list(base_cost = 1100, loss_frequency = 0.13, severity_mean = 9000, admin_costs = 190)
  ),
  Health = list(
    Iowa = list(base_cost = 2500, loss_frequency = 0.7, severity_mean = 3500, admin_costs = 400),
    Georgia = list(base_cost = 2800, loss_frequency = 0.8, severity_mean = 3800, admin_costs = 420),
    Florida = list(base_cost = 3200, loss_frequency = 0.85, severity_mean = 4000, admin_costs = 450)
  ),
  Life = list(
    Iowa = list(base_cost = 500, loss_frequency = 0.01, severity_mean = 50000, admin_costs = 100),
    Georgia = list(base_cost = 550, loss_frequency = 0.012, severity_mean = 55000, admin_costs = 110),
    Florida = list(base_cost = 600, loss_frequency = 0.015, severity_mean = 60000, admin_costs = 120)
  ),
  Annuities = list(
    Iowa = list(base_cost = 3000, loss_frequency = 1.0, severity_mean = 3000, admin_costs = 300),
    Georgia = list(base_cost = 3200, loss_frequency = 1.0, severity_mean = 3200, admin_costs = 320),
    Florida = list(base_cost = 3500, loss_frequency = 1.0, severity_mean = 3500, admin_costs = 350)
  )
)

#' Calculate consumer utility for an insurance product
#' 
#' @param line The insurance line (e.g., "Home", "Auto")
#' @param region The region (e.g., "Iowa", "Georgia", "Florida")
#' @param premium_adjustment The premium adjustment as a percentage (e.g., 100 for baseline)
#' @param service_quality Quality level of customer service (1-10)
#' @param brand_recognition Brand recognition score (1-10) 
#' @param bundling_discount Discount for bundling multiple products (percentage)
#' @param competitor_premium_avg Average premium of competitors
#' @return Calculated utility value for the product
calculate_utility <- function(line, region, premium_adjustment, service_quality = 5, 
                             brand_recognition = 5, bundling_discount = 0, 
                             competitor_premium_avg = 100) {
  
  # Get parameters for this line/region
  params <- base_utility_params[[line]][[region]]
  
  # Calculate base utility
  base_utility <- params$base_attraction
  
  # Price effect (negative - higher prices reduce utility)
  price_effect <- -1 * params$price_sensitivity * (premium_adjustment - 100)
  
  # Service quality effect (positive)
  service_effect <- 0.05 * service_quality
  
  # Brand recognition effect (positive)
  brand_effect <- 0.04 * brand_recognition
  
  # Bundling effect (positive with discount)
  bundling_effect <- 0.02 * bundling_discount
  
  # Competitor price effect (positive if competitors have higher prices)
  competitor_effect <- params$competitor_effect * (competitor_premium_avg - premium_adjustment)/100
  
  # Calculate total utility
  total_utility <- base_utility + price_effect + service_effect + 
                  brand_effect + bundling_effect + competitor_effect
  
  # Ensure utility is not negative
  return(max(0, total_utility))
}

#' Calculate expected market share based on utility
#' 
#' @param utility The utility of the product
#' @param competitor_utilities A vector of competitor utilities
#' @param outside_option_utility Utility of not purchasing (default = 1)
#' @return Market share percentage
calculate_market_share <- function(utility, competitor_utilities, outside_option_utility = 1) {
  # Sum of exponentials of all utilities including outside option
  denom <- exp(utility) + sum(exp(competitor_utilities)) + exp(outside_option_utility)
  
  # Market share using logit formula
  market_share <- exp(utility) / denom
  
  return(market_share * 100) # Convert to percentage
}

#' Simulate expected claims based on cost models
#' 
#' @param line The insurance line
#' @param region The region
#' @param policies_count Number of policies sold
#' @param risk_management_quality Quality of risk management (1-10)
#' @return A list with expected claims and admin costs
simulate_claims <- function(line, region, policies_count, risk_management_quality = 5) {
  # Get cost parameters for this line/region
  params <- base_cost_params[[line]][[region]]
  
  # Risk management reduces loss frequency
  adjusted_frequency <- params$loss_frequency * (1 - 0.02 * risk_management_quality)
  
  # Calculate expected number of claims
  expected_claim_count <- policies_count * adjusted_frequency
  
  # Calculate expected severity (with some randomness)
  expected_severity <- params$severity_mean * (1 - 0.01 * risk_management_quality)
  
  # Calculate total expected claims
  total_expected_claims <- expected_claim_count * expected_severity
  
  # Calculate admin costs
  total_admin_costs <- policies_count * params$admin_costs
  
  return(list(
    expected_claims = total_expected_claims,
    admin_costs = total_admin_costs,
    claim_count = expected_claim_count,
    average_severity = expected_severity
  ))
}

#' Calculate loss ratio and combined ratio
#' 
#' @param premium_revenue Total premium revenue
#' @param claims_paid Total claims paid
#' @param admin_costs Administrative costs
#' @return A list with loss ratio and combined ratio
calculate_ratios <- function(premium_revenue, claims_paid, admin_costs) {
  loss_ratio <- claims_paid / premium_revenue * 100
  combined_ratio <- (claims_paid + admin_costs) / premium_revenue * 100
  
  return(list(
    loss_ratio = loss_ratio,
    combined_ratio = combined_ratio
  ))
}

#' Simulate investment returns based on allocation and market conditions
#' 
#' @param equity_allocation Percentage allocated to equities
#' @param bond_allocation Percentage allocated to bonds
#' @param cash_allocation Percentage allocated to cash
#' @param market_condition Market condition factor (-1 to 1, with 0 being neutral)
#' @param investment_skill Investment skill level (1-10)
#' @return Expected annual return as a percentage
simulate_investment_returns <- function(equity_allocation, bond_allocation, cash_allocation,
                                      market_condition = 0, investment_skill = 5) {
  
  # Base expected returns for different asset classes
  equity_base_return <- 0.08  # 8% base return for equity
  bond_base_return <- 0.04    # 4% base return for bonds
  cash_base_return <- 0.01    # 1% base return for cash
  
  # Market condition affects equity and bond returns
  # Positive market conditions boost equity returns but may lower bond returns
  equity_adjusted_return <- equity_base_return + (0.06 * market_condition)
  bond_adjusted_return <- bond_base_return - (0.02 * market_condition)
  
  # Investment skill provides a small boost across all asset classes
  skill_boost <- 0.002 * (investment_skill - 5)
  
  # Calculate weighted average return
  weighted_return <- (equity_allocation/100 * (equity_adjusted_return + skill_boost)) +
                   (bond_allocation/100 * (bond_adjusted_return + skill_boost)) +
                   (cash_allocation/100 * (cash_base_return + skill_boost))
  
  return(weighted_return * 100)  # Return as percentage
}

#' Run a full simulation of market performance for a company
#' 
#' @param company_decisions List of company decisions (premium adjustments, etc.)
#' @param market_conditions List of market conditions
#' @return Comprehensive results of the simulation
run_simulation <- function(company_decisions, market_conditions) {
  results <- list()
  
  # Loop through each insurance line and region
  for (line in INSURANCE_LINES) {
    results[[line]] <- list()
    
    for (region in REGIONS) {
      # Extract decisions for this line/region
      premium_adj <- company_decisions$premium_adjustments[[line]][[region]]
      service_quality <- company_decisions$service_quality
      brand_recognition <- company_decisions$brand_recognition
      bundling_discount <- company_decisions$bundling_discount
      
      # Calculate utility
      utility <- calculate_utility(
        line, 
        region, 
        premium_adj,
        service_quality,
        brand_recognition,
        bundling_discount,
        market_conditions$competitor_premiums[[line]][[region]]
      )
      
      # Calculate market share
      market_share <- calculate_market_share(
        utility,
        market_conditions$competitor_utilities[[line]][[region]],
        market_conditions$outside_option_utility
      )
      
      # Calculate policies sold
      total_market_size <- market_conditions$market_sizes[[line]][[region]]
      policies_sold <- total_market_size * (market_share / 100)
      
      # Calculate premium revenue
      base_premium <- base_cost_params[[line]][[region]]$base_cost
      premium_revenue <- policies_sold * base_premium * (premium_adj / 100)
      
      # Calculate claims and expenses
      claims_results <- simulate_claims(
        line,
        region,
        policies_sold,
        company_decisions$risk_management_quality
      )
      
      # Calculate ratios
      ratios <- calculate_ratios(
        premium_revenue,
        claims_results$expected_claims,
        claims_results$admin_costs
      )
      
      # Store results for this line/region
      results[[line]][[region]] <- list(
        utility = utility,
        market_share = market_share,
        policies_sold = policies_sold,
        premium_revenue = premium_revenue,
        claims = claims_results$expected_claims,
        admin_costs = claims_results$admin_costs,
        loss_ratio = ratios$loss_ratio,
        combined_ratio = ratios$combined_ratio
      )
    }
  }
  
  # Calculate overall company metrics
  total_premium <- 0
  total_claims <- 0
  total_expenses <- 0
  
  for (line in INSURANCE_LINES) {
    for (region in REGIONS) {
      total_premium <- total_premium + results[[line]][[region]]$premium_revenue
      total_claims <- total_claims + results[[line]][[region]]$claims
      total_expenses <- total_expenses + results[[line]][[region]]$admin_costs
    }
  }
  
  # Calculate overall ratios
  overall_loss_ratio <- (total_claims / total_premium) * 100
  overall_combined_ratio <- ((total_claims + total_expenses) / total_premium) * 100
  
  # Calculate investment returns
  investment_return <- simulate_investment_returns(
    company_decisions$investment$equity_allocation,
    company_decisions$investment$bond_allocation,
    company_decisions$investment$cash_allocation,
    market_conditions$market_condition,
    company_decisions$investment_skill
  )
  
  # Calculate investment income
  investment_income <- total_premium * (investment_return / 100)
  
  # Calculate profit
  underwriting_profit <- total_premium - total_claims - total_expenses
  total_profit <- underwriting_profit + investment_income
  
  # Add company-level metrics to results
  results$company <- list(
    total_premium = total_premium,
    total_claims = total_claims,
    total_expenses = total_expenses,
    underwriting_profit = underwriting_profit,
    investment_income = investment_income,
    total_profit = total_profit,
    overall_loss_ratio = overall_loss_ratio,
    overall_combined_ratio = overall_combined_ratio,
    investment_return = investment_return
  )
  
  return(results)
}

# This line might cause circular dependencies, so let's conditionally source
if (!exists("validate_game_state")) {
  source("backend/validation.R")
}

#' Calculate the combined ratio
#'
#' @param revenue Total premium revenue
#' @param claims Total claims paid
#' @param expenses Total expenses
#' @return The combined ratio as a percentage
calculate_combined_ratio <- function(revenue, claims, expenses) {
  return((claims + expenses) / revenue * 100)
}

#' Calculate consumer utility for a given insurance product
#'
#' @param consumer A list containing consumer characteristics
#' @param product A list containing product characteristics
#' @return Utility value (higher is better)
calculate_consumer_utility <- function(consumer, product) {
  # Basic utility calculation using consumer and product parameters
  # This implements a simplified version of the BLP utility framework
  
  # Extract parameters
  price_sensitivity <- consumer$price_sensitivity
  risk_profile <- consumer$risk_profile
  
  premium <- product$premium
  expected_cost <- product$expected_cost
  quality <- product$quality
  advertising <- product$advertising
  
  # Calculate utility components
  price_utility <- -price_sensitivity * (premium / expected_cost - 1)
  quality_utility <- quality * 2  # Quality has a positive effect
  advertising_utility <- advertising * risk_profile  # Higher risk profiles are more influenced by advertising
  
  # Regional adjustments based on consumer's region
  region_factor <- switch(consumer$region,
                         "Iowa" = 1.0,
                         "Georgia" = 1.1,
                         "Florida" = 1.2,
                         1.0)  # Default if region not recognized
  
  # Combined utility with regional adjustment
  utility <- (price_utility + quality_utility + advertising_utility) * region_factor
  
  return(utility)
}

#' Simulate market demand based on current conditions
#'
#' @param market A list containing market characteristics
#' @param price_level The relative price level (1.0 = neutral)
#' @return A list containing volume and market share
simulate_market_demand <- function(market, price_level) {
  # Extract market parameters
  consumers <- market$consumers
  base_demand <- market$base_demand
  competitors <- market$competitors
  
  # Calculate base volume
  base_volume <- consumers * base_demand
  
  # Price elasticity effect
  price_effect <- exp(-1.5 * (price_level - 1))  # Exponential decrease with higher prices
  
  # Competition effect
  competition_effect <- 1 / (1 + 0.2 * competitors)
  
  # Calculate final volume
  volume <- base_volume * price_effect * competition_effect
  
  # Calculate market share (percentage of total potential market)
  market_share <- volume / consumers
  
  return(list(
    volume = volume,
    market_share = market_share
  ))
}

#' Calculate risk based on parameters
#'
#' @param params A list containing risk parameters
#' @return Risk value between 0 and 1
calculate_risk <- function(params) {
  # Extract parameters
  base_probability <- params$base_probability
  severity_multiplier <- params$severity_multiplier
  region_factor <- params$region_factor
  
  # Calculate risk
  risk <- base_probability * severity_multiplier * region_factor
  
  # Ensure risk is between 0 and 1
  risk <- max(0, min(1, risk))
  
  return(risk)
}

#' Run a full simulation step for a given turn
#'
#' @param game_state The current game state
#' @param player_decisions List of all player decisions for this turn
#' @return Updated game state after simulation
run_simulation_step <- function(game_state, player_decisions) {
  # Ensure the game state is valid
  game_state <- validate_game_state(game_state)
  
  # Process market conditions
  market_condition <- game_state$market_conditions$market_condition
  
  # Initialize results if they don't exist
  if (is.null(game_state$results)) {
    game_state$results <- list()
  }
  
  # Process each player's decisions
  results <- list()
  
  for (player_id in names(player_decisions)) {
    # Validate player decisions
    decisions <- validate_player_decisions(player_decisions[[player_id]])
    
    # Get player skills
    player_skills <- load_player_skills(player_id)
    
    # Apply skill effects to simulation parameters
    decisions <- apply_skill_effects(decisions, player_skills)
    
    # Check for unlocked features
    unlocked_features <- check_unlocked_features(player_skills)
    
    # Process premium adjustments
    premium_results <- process_premium_decisions(decisions$premium_adjustments, game_state)
    
    # Process investment decisions
    investment_results <- process_investment_decisions(decisions$investments, game_state)
    
    # Process risk management decisions
    risk_results <- process_risk_decisions(decisions$risk_management, game_state)
    
    # Calculate overall financial results
    financial_results <- calculate_financial_results(premium_results, investment_results, risk_results, game_state)
    
    # Store results for this player
    results[[player_id]] <- list(
      premium_results = premium_results,
      investment_results = investment_results,
      risk_results = risk_results,
      financial_results = financial_results
    )
    
    # Generate achievement-based skill point events
    achievement_events <- generate_achievement_events(financial_results, premium_results, investment_results, risk_results)
    
    # Process achievement events immediately
    for (event in achievement_events) {
      process_skill_point_event(event, player_id)
    }
  }
  
  # Store results in game state
  game_state$results <- results
  
  # Update market conditions for next turn
  game_state$market_conditions$market_condition <- update_market_conditions(market_condition, results)
  
  # Generate random events for next turn (includes skill point events)
  game_state$events <- generate_events(game_state)
  
  return(game_state)
}

#' Generate achievement-based skill point events based on player performance
#'
#' @param financial_results Financial results for the player
#' @param premium_results Premium adjustment results
#' @param investment_results Investment results
#' @param risk_results Risk management results
#' @return List of achievement events
generate_achievement_events <- function(financial_results, premium_results, investment_results, risk_results) {
  events <- list()
  
  # Check for financial achievements
  if (!is.null(financial_results$combined_ratio) && financial_results$combined_ratio < 95) {
    # Excellent combined ratio achievement
    event <- list(
      type = "skill_point",
      category = "performance",
      title = "Financial Performance Achievement",
      description = paste0("Achieved excellent combined ratio of ", round(financial_results$combined_ratio, 1), "%"),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Check for profit achievements
  if (!is.null(financial_results$profit) && financial_results$profit > 100000) {
    # High profit achievement
    event <- list(
      type = "skill_point",
      category = "performance",
      title = "Profit Achievement",
      description = paste0("Achieved outstanding annual profit of $", format(round(financial_results$profit / 1000, 0), nsmall = 0), "k"),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Check for investment achievements
  if (!is.null(investment_results$return_rate) && investment_results$return_rate > 0.1) {
    # High investment return achievement
    event <- list(
      type = "skill_point",
      category = "innovation",
      title = "Investment Excellence",
      description = paste0("Achieved exceptional investment returns of ", round(investment_results$return_rate * 100, 1), "%"),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Check for risk management achievements
  if (!is.null(risk_results$effectiveness) && risk_results$effectiveness > 0.8) {
    # Excellent risk management achievement
    event <- list(
      type = "skill_point",
      category = "risk_management",
      title = "Risk Management Excellence",
      description = "Implemented highly effective risk mitigation strategies",
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  return(events)
}

#' Process premium decisions for a player
#'
#' @param premium_adjustments The player's premium adjustment decisions
#' @param game_state The current game state
#' @return Results of premium decisions
process_premium_decisions <- function(premium_adjustments, game_state) {
  # Placeholder implementation
  return(list(
    volume = sample(1000:5000, 1),
    revenue = sample(10000:100000, 1),
    loss_ratio = runif(1, 0.6, 1.1)
  ))
}

#' Process investment decisions for a player
#'
#' @param investments The player's investment allocation decisions
#' @param game_state The current game state
#' @return Results of investment decisions
process_investment_decisions <- function(investments, game_state) {
  # Placeholder implementation
  return(list(
    return_rate = runif(1, -0.05, 0.15),
    total_return = sample(1000:50000, 1),
    risk_adjusted_return = runif(1, -0.02, 0.1)
  ))
}

#' Process risk management decisions for a player
#'
#' @param risk_management The player's risk management decisions
#' @param game_state The current game state
#' @return Results of risk management decisions
process_risk_decisions <- function(risk_management, game_state) {
  # Placeholder implementation
  return(list(
    risk_reduction = runif(1, 0, 0.3),
    cost = sample(5000:20000, 1),
    effectiveness = runif(1, 0.5, 1.0)
  ))
}

#' Calculate financial results based on various decision outcomes
#'
#' @param premium_results Results from premium decisions
#' @param investment_results Results from investment decisions
#' @param risk_results Results from risk management decisions
#' @param game_state The current game state
#' @return Overall financial results
calculate_financial_results <- function(premium_results, investment_results, risk_results, game_state) {
  # Calculate revenue
  revenue <- premium_results$revenue
  
  # Calculate investment income
  investment_income <- investment_results$total_return
  
  # Calculate claims
  claims <- premium_results$revenue * premium_results$loss_ratio
  
  # Calculate expenses (including risk management costs)
  expenses <- risk_results$cost + 0.1 * revenue  # Assume 10% of revenue goes to general expenses
  
  # Calculate profit
  profit <- revenue + investment_income - claims - expenses
  
  # Calculate combined ratio
  combined_ratio <- calculate_combined_ratio(revenue, claims, expenses)
  
  return(list(
    revenue = revenue,
    investment_income = investment_income,
    claims = claims,
    expenses = expenses,
    profit = profit,
    combined_ratio = combined_ratio,
    return_on_equity = profit / (revenue * 0.5)  # Simplified ROE calculation
  ))
}

#' Update market conditions based on current state and results
#'
#' @param current_condition The current market condition
#' @param results All player results
#' @return Updated market condition
update_market_conditions <- function(current_condition, results) {
  # Simple random walk with mean reversion
  random_factor <- runif(1, -0.1, 0.1)
  mean_reversion <- 0.1 * (0.5 - current_condition)  # Revert toward neutral (0.5)
  
  new_condition <- current_condition + random_factor + mean_reversion
  
  # Ensure the condition stays between 0 and 1
  new_condition <- max(0, min(1, new_condition))
  
  return(new_condition)
}

#' Generate random events based on game state
#'
#' @param game_state The current game state
#' @return List of events
generate_events <- function(game_state) {
  events <- list()
  
  # Chance of catastrophe events
  regions <- c("Iowa", "Georgia", "Florida")
  
  for (region in regions) {
    prob <- game_state$parameters$catastrophe_probability[[region]]
    
    if (runif(1) < prob) {
      # Generate a catastrophe event
      event <- list(
        type = "catastrophe",
        region = region,
        description = generate_catastrophe_description(region),
        magnitude = runif(1, 0.1, 1.0),
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
      
      events[[length(events) + 1]] <- event
    }
  }
  
  # Regulatory events
  for (region in regions) {
    strictness <- game_state$parameters$regulator_strictness[[region]]
    
    if (runif(1) < strictness * 0.2) {
      # Generate a regulatory event
      event <- list(
        type = "regulatory",
        region = region,
        description = generate_regulatory_description(region, strictness),
        magnitude = strictness * runif(1, 0.5, 1.0),
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
      
      events[[length(events) + 1]] <- event
    }
  }
  
  # Market events (general events affecting all players)
  if (runif(1) < 0.3) {
    event <- list(
      type = "market",
      region = "all",
      description = generate_market_description(game_state$market_conditions$market_condition),
      magnitude = runif(1, 0.1, 0.5),
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    
    events[[length(events) + 1]] <- event
  }
  
  # Generate skill point events (new addition)
  skill_events <- generate_skill_point_events(game_state)
  events <- c(events, skill_events)
  
  return(c(game_state$events, events))
}

#' Generate a description for a catastrophe event
#'
#' @param region The affected region
#' @return Description string
generate_catastrophe_description <- function(region) {
  catastrophes <- list(
    Iowa = c(
      "Severe flooding along the Mississippi River",
      "Tornado outbreak in eastern counties",
      "Drought affecting agricultural areas"
    ),
    Georgia = c(
      "Hurricane makes landfall on coastal areas",
      "Severe thunderstorms cause widespread damage",
      "Flooding in metropolitan Atlanta"
    ),
    Florida = c(
      "Major hurricane hits southern peninsula",
      "Tropical storm causes coastal flooding",
      "Sinkholes reported in central region"
    )
  )
  
  return(sample(catastrophes[[region]], 1))
}

#' Generate a description for a regulatory event
#'
#' @param region The affected region
#' @param strictness The regulatory strictness
#' @return Description string
generate_regulatory_description <- function(region, strictness) {
  if (strictness > 0.7) {
    # Strict regulations
    descriptions <- c(
      paste("New rate caps implemented in", region),
      paste("Enhanced consumer protection laws in", region),
      paste("Stricter solvency requirements in", region)
    )
  } else {
    # Moderate regulations
    descriptions <- c(
      paste("Regulatory review of pricing practices in", region),
      paste("New filing requirements in", region),
      paste("Updated consumer disclosure rules in", region)
    )
  }
  
  return(sample(descriptions, 1))
}

#' Generate a description for a market event
#'
#' @param market_condition The current market condition
#' @return Description string
generate_market_description <- function(market_condition) {
  if (market_condition > 0.7) {
    # Favorable market
    descriptions <- c(
      "Stock market reaches new high",
      "Interest rates increase, boosting investment income",
      "Economic growth accelerates"
    )
  } else if (market_condition < 0.3) {
    # Unfavorable market
    descriptions <- c(
      "Market correction affects investment portfolios",
      "Interest rates fall to historic lows",
      "Economic slowdown affects consumer spending"
    )
  } else {
    # Neutral market
    descriptions <- c(
      "Minor fluctuations in financial markets",
      "Moderate economic indicators released",
      "Steady market conditions continue"
    )
  }
  
  return(sample(descriptions, 1))
}

#' Process player decisions for a player
#'
#' @param player_id The player's ID
#' @param decisions The player's decisions
#' @param game_state The current game state
#' @return Processed decisions with skill effects applied
process_player_decisions <- function(player_id, decisions, game_state) {
  # Get player skills
  player_skills <- load_player_skills(player_id)
  
  # Apply skill effects to simulation parameters
  decisions <- apply_skill_effects(decisions, player_skills)
  
  # Check for unlocked features
  unlocked_features <- check_unlocked_features(player_skills)
  
  # Process decisions with skill-enhanced parameters
  # ... existing code ...
  
  # Return the processed decisions with skill effects applied
  return(decisions)
}

#' Process yearly update for a player
#'
#' @param game_state The current game state
#' @param player_decisions List of all player decisions for this turn
#' @return Updated game state after processing yearly update
process_yearly_update <- function(game_state, player_decisions) {
  # ... existing code ...
  
  # Award skill points based on performance
  for (player_id in names(player_decisions)) {
    # Calculate performance score based on financial results
    performance_score <- calculate_performance_score(player_decisions[[player_id]], game_state)
    
    # Award skill points (1-3 based on performance)
    skill_points <- min(max(floor(performance_score / 25), 1), 3)
    award_skill_points(player_id, skill_points)
  }
  
  # ... rest of existing code ...
}

#' Calculate performance score for a player
#'
#' @param decisions The player's decisions
#' @param game_state The current game state
#' @return Performance score
calculate_performance_score <- function(decisions, game_state) {
  # This is a simplified example - adjust based on your actual simulation logic
  score <- 0
  
  # Add points for good financial performance
  if (!is.null(decisions$financial) && !is.null(decisions$financial$combined_ratio)) {
    # Lower combined ratio is better
    if (decisions$financial$combined_ratio < 95) {
      score <- score + 50
    } else if (decisions$financial$combined_ratio < 100) {
      score <- score + 25
    }
  }
  
  # Add points for market share growth
  if (!is.null(decisions$market) && !is.null(decisions$market$share_change)) {
    if (decisions$market$share_change > 0.5) {
      score <- score + 50
    } else if (decisions$market$share_change > 0) {
      score <- score + 25
    }
  }
  
  # Add points for investment returns
  if (!is.null(decisions$financial) && !is.null(decisions$financial$investment_return)) {
    if (decisions$financial$investment_return > 8) {
      score <- score + 50
    } else if (decisions$financial$investment_return > 5) {
      score <- score + 25
    }
  }
  
  return(score)
}

#' Generate skill point award events
#'
#' @param game_state The current game state
#' @return List of skill point events
generate_skill_point_events <- function(game_state) {
  events <- list()
  
  # Performance achievement events
  if (runif(1) < 0.4) { # 40% chance of a performance event
    event <- list(
      type = "skill_point",
      category = "performance",
      title = "Quarterly Performance Achievement",
      description = sample(c(
        "Achieved quarterly profit target",
        "Met underwriting performance goals",
        "Exceeded revenue forecasts for the quarter",
        "Achieved target loss ratio for major product line",
        "Reduced operational expenses below target"
      ), 1),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Innovation events (less frequent but more points)
  if (runif(1) < 0.2) { # 20% chance of an innovation event
    event <- list(
      type = "skill_point",
      category = "innovation",
      title = "Innovation Milestone",
      description = sample(c(
        "Successfully implemented new digital platform",
        "Launched innovative insurance product",
        "Modernized claims processing system",
        "Introduced AI-based risk assessment",
        "Deployed new customer service technology"
      ), 1),
      points = 2,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Educational events
  if (runif(1) < 0.3) { # 30% chance of an educational event
    event <- list(
      type = "skill_point",
      category = "educational",
      title = "Educational Achievement",
      description = sample(c(
        "Completed executive training program",
        "Team completed risk management certification",
        "Invested in employee development programs",
        "Participated in industry leadership workshop",
        "Conducted company-wide actuarial training"
      ), 1),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  # Risk management success events
  if (runif(1) < 0.25) { # 25% chance of a risk management event
    event <- list(
      type = "skill_point",
      category = "risk_management",
      title = "Risk Management Success",
      description = sample(c(
        "Successfully mitigated major risk exposure",
        "Implemented effective reinsurance strategy",
        "Prevented significant catastrophe losses",
        "Optimized capital allocation for risk management",
        "Improved risk modeling accuracy"
      ), 1),
      points = 1,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    events[[length(events) + 1]] <- event
  }
  
  return(events)
}

#' Process all events and apply their effects
#'
#' @param game_state The current game state
#' @param player_id The player's ID to apply effects to
#' @return Updated game state with event effects applied
process_events <- function(game_state, player_id) {
  if (is.null(game_state$events) || length(game_state$events) == 0) {
    return(game_state)
  }
  
  for (event in game_state$events) {
    if (event$type == "skill_point") {
      # Process skill point events
      process_skill_point_event(event, player_id)
    }
    
    # Process other event types (existing logic)
    # ...
  }
  
  return(game_state)
}

#' Process a skill point event and award points to player
#'
#' @param event The skill point event
#' @param player_id The player's ID
#' @return TRUE if successfully processed, FALSE otherwise
process_skill_point_event <- function(event, player_id) {
  if (is.null(player_id)) {
    return(FALSE)
  }
  
  # Award skill points to the player
  award_result <- award_skill_points(
    player_id = player_id,
    points_to_award = event$points,
    description = event$description
  )
  
  # Create inbox message for the event
  if (!is.null(award_result)) {
    create_skill_point_inbox_message(player_id, event)
    return(TRUE)
  }
  
  return(FALSE)
}

#' Create an inbox message for a skill point event
#'
#' @param player_id The player's ID
#' @param event The skill point event
#' @return TRUE if message created successfully, FALSE otherwise
create_skill_point_inbox_message <- function(player_id, event) {
  # Create a filename for the inbox message
  message_dir <- "data/inbox"
  if (!dir.exists(message_dir)) {
    dir.create(message_dir, recursive = TRUE)
  }
  
  # Create message content
  message <- list(
    id = paste0("msg_", format(Sys.time(), "%Y%m%d%H%M%S"), "_", sample(1000:9999, 1)),
    player_id = player_id,
    title = event$title,
    sender = get_sender_for_category(event$category),
    content = paste0(
      "Congratulations! You've earned ", event$points, " skill point", 
      ifelse(event$points > 1, "s", ""), " for: ", event$description, 
      ". Visit the Tech Tree to allocate your new skill points."
    ),
    timestamp = event$timestamp,
    is_read = FALSE,
    category = "skill_points"
  )
  
  # Save message to file
  filename <- file.path(message_dir, paste0(message$id, ".json"))
  result <- tryCatch({
    write_json(message, filename, pretty = TRUE, auto_unbox = TRUE)
    TRUE
  }, error = function(e) {
    message("Error creating inbox message: ", e$message)
    FALSE
  })
  
  return(result)
}

#' Get appropriate sender name based on event category
#'
#' @param category The event category
#' @return Sender name string
get_sender_for_category <- function(category) {
  switch(category,
         "performance" = "CFO Office",
         "innovation" = "CCO Office",
         "educational" = "Human Resources",
         "risk_management" = "CRO Office",
         "CEO Office" # Default sender
  )
} 