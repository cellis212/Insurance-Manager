library(testthat)
library(shiny)

# Source our backend modules with correct paths
source("../../backend/validation.R")
source("../../backend/simulation.R")

test_that("Consumer utility calculation works", {
  # Test data
  test_consumer <- list(
    risk_profile = 0.5,
    price_sensitivity = 1.2,
    region = "Iowa"
  )
  
  test_product <- list(
    premium = 100,
    expected_cost = 80,
    quality = 0.7,
    advertising = 0.5
  )
  
  # Call utility function from simulation.R
  utility <- calculate_consumer_utility(test_consumer, test_product)
  
  # Assertions
  expect_type(utility, "double")
  expect_gte(utility, -10)
  expect_lte(utility, 10)
})

test_that("Market demand simulation gives reasonable results", {
  # Test market conditions
  market <- list(
    consumers = 1000,
    base_demand = 0.6,
    competitors = 3
  )
  
  # Call demand simulation function
  demand <- simulate_market_demand(market, price_level = 1.0)
  
  # Assertions
  expect_type(demand, "list")
  expect_true("volume" %in% names(demand))
  expect_true("market_share" %in% names(demand))
  expect_gte(demand$volume, 0)
  expect_lte(demand$market_share, 1.0)
})

test_that("Risk function works with different parameters", {
  # Test low risk scenario
  low_risk_params <- list(
    base_probability = 0.05,
    severity_multiplier = 1.2,
    region_factor = 0.8
  )
  
  # Test high risk scenario
  high_risk_params <- list(
    base_probability = 0.15,
    severity_multiplier = 2.0,
    region_factor = 1.5
  )
  
  # Calculate risk for both scenarios
  low_risk <- calculate_risk(low_risk_params)
  high_risk <- calculate_risk(high_risk_params)
  
  # Assertions
  expect_type(low_risk, "double")
  expect_type(high_risk, "double")
  expect_lt(low_risk, high_risk)  # High risk should be higher than low risk
  expect_gte(low_risk, 0)
  expect_lte(high_risk, 1)
})

test_that("Combined ratio calculation is correct", {
  # Test data
  premiums <- 1000
  claims <- 700
  expenses <- 200
  
  # Calculate combined ratio
  ratio <- calculate_combined_ratio(premiums, claims, expenses)
  
  # Expected combined ratio: (claims + expenses) / premiums
  expected_ratio <- (700 + 200) / 1000
  
  # Assertions
  expect_equal(ratio, expected_ratio)
})

# Mock test for things that might depend on external files or complex state
test_that("Game state functions handle missing data", {
  # Mock game state with missing values
  test_state <- list(
    market_conditions = list(
      market_condition = NULL
    ),
    parameters = list(
      regulator_strictness = list(
        Iowa = 0.5,
        Georgia = NULL,
        Florida = 0.8
      )
    )
  )
  
  # Validate state should handle missing values
  validated <- validate_game_state(test_state)
  
  # Assertions
  expect_type(validated, "list")
  expect_true(validated$market_conditions$market_condition == 0.5)  # Should be default
  expect_equal(validated$parameters$regulator_strictness$Georgia, 0.7)  # Should be default
}) 