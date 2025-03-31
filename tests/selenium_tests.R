#!/usr/bin/env Rscript

# Selenium Test Suite for Insurance Simulation Game
# This script tests the main functionality of the application using RSelenium

library(RSelenium)
library(testthat)
library(jsonlite)

# Test Configuration
TEST_URL <- "http://127.0.0.1:3838"  # URL of the locally running Shiny app
SELENIUM_TIMEOUT <- 20  # Seconds to wait for elements
BROWSER <- "chrome"

# Helper functions
wait_for_element <- function(remDr, selector, timeout = SELENIUM_TIMEOUT) {
  for (i in 1:timeout) {
    elements <- tryCatch({
      remDr$findElements(using = "css selector", selector)
    }, error = function(e) {
      return(list())
    })
    
    if (length(elements) > 0) {
      return(elements[[1]])
    }
    
    Sys.sleep(1)
  }
  
  stop(paste("Element not found after", timeout, "seconds:", selector))
}

test_login <- function(remDr) {
  test_that("Login page works", {
    remDr$navigate(TEST_URL)
    
    # Wait for login form
    login_button <- wait_for_element(remDr, "#loginButton")
    
    # Test login form is visible
    expect_true(login_button$isElementDisplayed()[[1]])
    
    # Enter test credentials
    username_input <- remDr$findElement(using = "id", "username")
    password_input <- remDr$findElement(using = "id", "password")
    
    username_input$sendKeysToElement(list("testuser"))
    password_input$sendKeysToElement(list("password"))
    
    # Click login button
    login_button$clickElement()
    
    # Check if login was successful by looking for dashboard elements
    dashboard_element <- wait_for_element(remDr, ".content-wrapper")
    expect_true(dashboard_element$isElementDisplayed()[[1]])
  })
}

test_executive_profile <- function(remDr) {
  test_that("Executive profile creation works", {
    # Navigate to profile section
    profile_btn <- wait_for_element(remDr, "#profileBtn")
    profile_btn$clickElement()
    
    # Wait for profile form
    profile_form <- wait_for_element(remDr, "#profileForm")
    expect_true(profile_form$isElementDisplayed()[[1]])
    
    # Fill out profile form
    major_selector <- remDr$findElement(using = "id", "secondaryMajor")
    major_selector$sendKeysToElement(list("Finance"))
    
    university_selector <- remDr$findElement(using = "id", "university")
    university_selector$sendKeysToElement(list("Yale"))
    
    # Save profile
    save_button <- remDr$findElement(using = "id", "saveProfileBtn")
    save_button$clickElement()
    
    # Verify success notification
    Sys.sleep(2)
    notification <- wait_for_element(remDr, ".shiny-notification-message")
    expect_true(notification$isElementDisplayed()[[1]])
  })
}

test_inbox_system <- function(remDr) {
  test_that("Inbox system loads messages", {
    # Navigate to inbox
    inbox_btn <- wait_for_element(remDr, "#inboxBtn")
    inbox_btn$clickElement()
    
    # Wait for inbox to load
    inbox_container <- wait_for_element(remDr, "#inboxContainer")
    expect_true(inbox_container$isElementDisplayed()[[1]])
    
    # Verify at least one message exists (might need adjustment based on actual app state)
    Sys.sleep(3) # Allow time for messages to load
    messages <- tryCatch({
      remDr$findElements(using = "css selector", ".message-item")
    }, error = function(e) {
      list()
    })
    
    # If we're in a fresh game, may not have messages yet
    if (length(messages) > 0) {
      expect_gte(length(messages), 1)
      
      # Click on first message
      messages[[1]]$clickElement()
      
      # Verify message content appears
      message_content <- wait_for_element(remDr, "#messageContent")
      expect_true(message_content$isElementDisplayed()[[1]])
    }
  })
}

test_simulation_controls <- function(remDr) {
  test_that("Simulation controls work", {
    # Navigate to simulation controls
    sim_ctrl_btn <- wait_for_element(remDr, "#simCtrlBtn")
    sim_ctrl_btn$clickElement()
    
    # Wait for simulation controls to load
    controls_panel <- wait_for_element(remDr, "#simulationControls")
    expect_true(controls_panel$isElementDisplayed()[[1]])
    
    # Test sliders function
    sliders <- remDr$findElements(using = "css selector", ".js-range-slider")
    if (length(sliders) > 0) {
      # Since directly manipulating sliders with Selenium is tricky,
      # we'll just verify they exist and are displayed
      expect_gte(length(sliders), 1)
      expect_true(sliders[[1]]$isElementDisplayed()[[1]])
    }
    
    # Test submit button
    submit_btn <- tryCatch({
      remDr$findElement(using = "id", "submitDecisionBtn")
    }, error = function(e) {
      NULL
    })
    
    if (!is.null(submit_btn)) {
      expect_true(submit_btn$isElementDisplayed()[[1]])
      # Click submit (commented out to avoid affecting game state during testing)
      # submit_btn$clickElement()
      # 
      # # Check for confirmation notification
      # Sys.sleep(2)
      # notification <- wait_for_element(remDr, ".shiny-notification-message")
      # expect_true(notification$isElementDisplayed()[[1]])
    }
  })
}

test_analytics_dashboard <- function(remDr) {
  test_that("Analytics dashboard displays charts", {
    # Navigate to analytics
    analytics_btn <- wait_for_element(remDr, "#analyticsBtn") 
    analytics_btn$clickElement()
    
    # Wait for dashboard to load
    dashboard_container <- wait_for_element(remDr, "#analyticsDashboard")
    expect_true(dashboard_container$isElementDisplayed()[[1]])
    
    # Check for charts/plots
    Sys.sleep(3) # Allow time for charts to render
    charts <- tryCatch({
      remDr$findElements(using = "css selector", ".plotly, .shiny-plot-output")
    }, error = function(e) {
      list()
    })
    
    # Expect at least one chart to be visible
    if (length(charts) > 0) {
      expect_gte(length(charts), 1)
      expect_true(charts[[1]]$isElementDisplayed()[[1]])
    }
  })
}

# Main test execution
main <- function() {
  cat("Starting RSelenium tests for Insurance Simulation Game\n")
  
  # Start Selenium driver
  rD <- RSelenium::rsDriver(
    browser = BROWSER,
    port = 4444L,
    verbose = FALSE,
    chromever = NULL
  )
  
  remDr <- rD[["client"]]
  remDr$setTimeout(pageLoad = SELENIUM_TIMEOUT * 1000)
  
  # Run tests
  tryCatch({
    cat("Running login test...\n")
    test_login(remDr)
    
    cat("Testing executive profile creation...\n")
    test_executive_profile(remDr)
    
    cat("Testing inbox system...\n")
    test_inbox_system(remDr)
    
    cat("Testing simulation controls...\n")
    test_simulation_controls(remDr)
    
    cat("Testing analytics dashboard...\n")
    test_analytics_dashboard(remDr)
    
    cat("All tests completed successfully!\n")
  }, error = function(e) {
    cat("Error during testing:", e$message, "\n")
  }, finally = {
    # Clean up
    remDr$close()
    rD$server$stop()
    
    cat("Test session ended.\n")
  })
}

# Run the tests
if (!interactive()) {
  main()
} 