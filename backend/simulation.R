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