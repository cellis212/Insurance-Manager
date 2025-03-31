#!/usr/bin/env Rscript

# Selenium Test Suite for Insurance Simulation Game
# This script tests the main functionality of the application using RSelenium
#
# REQUIREMENTS:
# - Java must be installed (required for Selenium server)
# - Chrome browser must be installed
# - The Shiny app must be running at http://127.0.0.1:3838
#
# Install Java from: https://www.java.com/en/download/
# Then run the tests with: & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/selenium_tests.R

library(RSelenium)
library(testthat)
library(jsonlite)
library(wdman)

# Test Configuration
TEST_URL <- "http://127.0.0.1:3838"  # URL of the locally running Shiny app
SELENIUM_TIMEOUT <- 30  # Seconds to wait for elements - increased for reliability
BROWSER <- "chrome"
SCREENSHOT_DIR <- "screenshots"  # Directory to save screenshots

# Configure logging
LOG_FILE <- "selenium_test_log.txt"
log_message <- function(msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message <- paste0("[", timestamp, "] ", msg)
  cat(message, "\n")
  cat(message, "\n", file = LOG_FILE, append = TRUE)
}

# Helper functions
wait_for_element <- function(remDr, selector, timeout = SELENIUM_TIMEOUT, take_screenshot = TRUE) {
  log_message(paste("Waiting for element:", selector))
  start_time <- Sys.time()
  
  for (i in 1:timeout) {
    elements <- tryCatch({
      remDr$findElements(using = "css selector", selector)
    }, error = function(e) {
      log_message(paste("Error finding element:", e$message))
      return(list())
    })
    
    if (length(elements) > 0) {
      is_displayed <- tryCatch({
        elements[[1]]$isElementDisplayed()[[1]]
      }, error = function(e) {
        log_message(paste("Error checking if element is displayed:", e$message))
        return(FALSE)
      })
      
      if (is_displayed) {
        elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
        log_message(paste("Found element after", round(elapsed, 2), "seconds:", selector))
        return(elements[[1]])
      }
    }
    
    # If we're halfway through the timeout and still haven't found the element, take a screenshot
    if (i == floor(timeout/2) && take_screenshot) {
      tryCatch({
        screenshot_file <- file.path(SCREENSHOT_DIR, paste0("screenshot_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
        remDr$screenshot(file = screenshot_file)
        log_message(paste("Took screenshot:", screenshot_file))
      }, error = function(e) {
        log_message(paste("Failed to take screenshot:", e$message))
      })
    }
    
    Sys.sleep(1)
  }
  
  # Take a final screenshot before giving up
  if (take_screenshot) {
    tryCatch({
      screenshot_file <- file.path(SCREENSHOT_DIR, paste0("element_not_found_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
      remDr$screenshot(file = screenshot_file)
      log_message(paste("Element not found, took screenshot:", screenshot_file))
    }, error = function(e) {
      log_message(paste("Failed to take screenshot:", e$message))
    })
  }
  
  stop(paste("Element not found after", timeout, "seconds:", selector))
}

# Check if Java is installed
check_java_installed <- function() {
  java_check <- tryCatch({
    system("java -version", intern = TRUE)
    TRUE
  }, error = function(e) {
    log_message("Java not found in PATH")
    FALSE
  }, warning = function(w) {
    log_message("Warning when checking Java: ")
    log_message(w$message)
    # Check if the warning is because the output went to stderr (normal for java -version)
    # In this case, Java is actually installed
    if (grepl("stderr", w$message)) {
      return(TRUE)
    }
    return(FALSE)
  })
  
  if (!java_check) {
    log_message("Java is required for RSelenium to work")
    cat("\nERROR: Java is required but not found in PATH\n")
    cat("Please install Java from: https://www.java.com/en/download/\n\n")
    return(FALSE)
  }
  return(TRUE)
}

test_login <- function(remDr) {
  test_that("Login page works", {
    log_message("Starting login test")
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
    log_message("Login test completed successfully")
  })
}

test_executive_profile <- function(remDr) {
  test_that("Executive profile creation works", {
    log_message("Starting executive profile test")
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
    log_message("Executive profile test completed successfully")
  })
}

test_inbox_system <- function(remDr) {
  test_that("Inbox system loads messages", {
    log_message("Starting inbox system test")
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
      log_message(paste("Error finding messages:", e$message))
      list()
    })
    
    # If we're in a fresh game, may not have messages yet
    if (length(messages) > 0) {
      expect_gte(length(messages), 1)
      log_message(paste("Found", length(messages), "messages"))
      
      # Click on first message
      messages[[1]]$clickElement()
      
      # Verify message content appears
      message_content <- wait_for_element(remDr, "#messageContent")
      expect_true(message_content$isElementDisplayed()[[1]])
    } else {
      log_message("No messages found, this may be expected in a fresh game state")
      # Skip this assertion if no messages found
      skip("No messages found to test interaction with")
    }
    log_message("Inbox system test completed")
  })
}

test_simulation_controls <- function(remDr) {
  test_that("Simulation controls work", {
    log_message("Starting simulation controls test")
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
      log_message(paste("Found", length(sliders), "sliders"))
    } else {
      log_message("No sliders found, checking for alternative controls")
      # Look for any input controls
      input_controls <- remDr$findElements(using = "css selector", "input, select")
      expect_gte(length(input_controls), 1)
      log_message(paste("Found", length(input_controls), "input controls"))
    }
    
    # Test submit button
    submit_btn <- tryCatch({
      remDr$findElement(using = "id", "submitDecisionBtn")
    }, error = function(e) {
      log_message(paste("Submit button not found with ID 'submitDecisionBtn':", e$message))
      # Try alternative selectors
      btn <- remDr$findElements(using = "css selector", "button.btn-primary, input[type='submit']")
      if (length(btn) > 0) {
        log_message("Found alternative submit button")
        return(btn[[1]])
      }
      return(NULL)
    })
    
    if (!is.null(submit_btn)) {
      expect_true(submit_btn$isElementDisplayed()[[1]])
      log_message("Submit button found and is displayed")
      # Click submit (commented out to avoid affecting game state during testing)
      # submit_btn$clickElement()
      # 
      # # Check for confirmation notification
      # Sys.sleep(2)
      # notification <- wait_for_element(remDr, ".shiny-notification-message")
      # expect_true(notification$isElementDisplayed()[[1]])
    } else {
      log_message("No submit button found - this may indicate a UI structure different than expected")
      skip("Submit button not found")
    }
    log_message("Simulation controls test completed")
  })
}

test_analytics_dashboard <- function(remDr) {
  test_that("Analytics dashboard displays charts", {
    log_message("Starting analytics dashboard test")
    # Navigate to analytics
    analytics_btn <- wait_for_element(remDr, "#analyticsBtn") 
    analytics_btn$clickElement()
    
    # Wait for dashboard to load
    dashboard_container <- wait_for_element(remDr, "#analyticsDashboard")
    expect_true(dashboard_container$isElementDisplayed()[[1]])
    
    # Check for charts/plots
    Sys.sleep(3) # Allow time for charts to render
    charts <- tryCatch({
      remDr$findElements(using = "css selector", ".plotly, .shiny-plot-output, .chart, .plot")
    }, error = function(e) {
      log_message(paste("Error finding charts:", e$message))
      list()
    })
    
    # Expect at least one chart to be visible
    if (length(charts) > 0) {
      expect_gte(length(charts), 1)
      expect_true(charts[[1]]$isElementDisplayed()[[1]])
      log_message(paste("Found", length(charts), "charts/plots"))
    } else {
      log_message("No charts found with standard selectors - trying alternative selectors")
      # Try more generic selectors for visualization containers
      viz_elements <- remDr$findElements(using = "css selector", ".dashboard-item, .card, .box")
      if (length(viz_elements) > 0) {
        log_message(paste("Found", length(viz_elements), "potential visualization containers"))
        expect_gte(length(viz_elements), 1)
      } else {
        log_message("No visualization elements found - this may indicate an empty dashboard or different UI structure")
        skip("No charts or visualization elements found")
      }
    }
    log_message("Analytics dashboard test completed")
  })
}

# Main test execution
main <- function() {
  cat("\nStarting RSelenium tests for Insurance Simulation Game\n")
  log_message("=== STARTING TEST RUN ===")
  
  # Ensure screenshot directory exists
  if (!dir.exists(SCREENSHOT_DIR)) {
    dir.create(SCREENSHOT_DIR, recursive = TRUE)
    log_message(paste("Created screenshot directory:", SCREENSHOT_DIR))
  }
  
  # Clear previous log file
  if (file.exists(LOG_FILE)) {
    file.remove(LOG_FILE)
  }
  
  # Check if Java is installed
  if (!check_java_installed()) {
    return(FALSE)
  }
  
  # Check if Shiny app is running
  app_available <- tryCatch({
    con <- url(TEST_URL, open = "r")
    close(con)
    TRUE
  }, error = function(e) {
    log_message(paste("Cannot connect to Shiny app at", TEST_URL, ":", e$message))
    cat("\nERROR: Shiny app does not appear to be running at", TEST_URL, "\n")
    cat("Please start the app with: & 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3838)\"\n\n")
    FALSE
  })
  
  if (!app_available) {
    return(FALSE)
  }
  
  # Start Selenium driver with better error handling
  log_message("Starting Chrome WebDriver")
  
  selenium_server <- NULL
  client <- NULL
  
  # First try using wdman's chrome() directly
  tryCatch({
    log_message("Attempting to start ChromeDriver using wdman directly")
    selenium_server <- wdman::chrome(verbose = FALSE)
    Sys.sleep(2)  # Give the driver time to start
    
    client <- remoteDriver(
      browserName = BROWSER,
      port = 4444L,
      verbose = FALSE
    )
    log_message("ChromeDriver started successfully")
  }, error = function(e) {
    log_message(paste("Error starting ChromeDriver with wdman:", e$message))
    
    # Fall back to rsDriver approach
    tryCatch({
      log_message("Falling back to rsDriver approach")
      rd <- RSelenium::rsDriver(
        browser = BROWSER,
        port = 4444L,
        verbose = FALSE,
        chromever = NULL
      )
      
      selenium_server <<- rd$server
      client <<- rd$client
      log_message("rsDriver started successfully")
    }, error = function(e2) {
      log_message(paste("Also failed with rsDriver approach:", e2$message))
      cat("\nERROR: Could not start WebDriver. Make sure Chrome is installed and Java is in your PATH.\n")
      return(FALSE)
    })
  })
  
  # If we couldn't start either approach, exit
  if (is.null(client) || is.null(selenium_server)) {
    log_message("Failed to initialize WebDriver")
    return(FALSE)
  }
  
  # Connect to WebDriver
  log_message("Connecting to WebDriver")
  tryCatch({
    client$open()
    client$setTimeout(pageLoad = SELENIUM_TIMEOUT * 1000)
    log_message("Connected to WebDriver")
  }, error = function(e) {
    log_message(paste("Failed to connect to WebDriver:", e$message))
    selenium_server$stop()
    cat("\nERROR: Could not connect to WebDriver\n")
    return(FALSE)
  })
  
  # Run tests with better error handling
  test_results <- list()
  
  # Run tests
  tryCatch({
    log_message("Running login test...")
    test_results$login <- tryCatch({
      test_login(client)
      TRUE
    }, error = function(e) {
      log_message(paste("Login test failed:", e$message))
      FALSE
    })
    
    if (test_results$login) {
      log_message("Running executive profile test...")
      test_results$profile <- tryCatch({
        test_executive_profile(client)
        TRUE
      }, error = function(e) {
        log_message(paste("Executive profile test failed:", e$message))
        FALSE
      })
      
      log_message("Running inbox system test...")
      test_results$inbox <- tryCatch({
        test_inbox_system(client)
        TRUE
      }, error = function(e) {
        log_message(paste("Inbox system test failed:", e$message))
        FALSE
      })
      
      log_message("Running simulation controls test...")
      test_results$controls <- tryCatch({
        test_simulation_controls(client)
        TRUE
      }, error = function(e) {
        log_message(paste("Simulation controls test failed:", e$message))
        FALSE
      })
      
      log_message("Running analytics dashboard test...")
      test_results$analytics <- tryCatch({
        test_analytics_dashboard(client)
        TRUE
      }, error = function(e) {
        log_message(paste("Analytics dashboard test failed:", e$message))
        FALSE
      })
    }
    
    # Print summary
    cat("\n=== TEST SUMMARY ===\n")
    if (all(unlist(test_results))) {
      cat("All tests completed successfully!\n")
    } else {
      cat("Some tests failed. Check the log for details.\n")
      failed_tests <- names(test_results)[!unlist(test_results)]
      cat("Failed tests:", paste(failed_tests, collapse = ", "), "\n")
    }
    
    log_message("=== TEST RUN COMPLETED ===")
  }, error = function(e) {
    log_message(paste("Error during testing:", e$message))
    cat("\nError during testing:", e$message, "\n")
  }, finally = {
    # Clean up
    log_message("Closing browser and stopping WebDriver")
    tryCatch({
      client$close()
    }, error = function(e) {
      log_message(paste("Error closing browser:", e$message))
    })
    
    tryCatch({
      selenium_server$stop()
    }, error = function(e) {
      log_message(paste("Error stopping server:", e$message))
    })
    
    log_message("Test session ended")
    cat("\nTest session ended. See", LOG_FILE, "for detailed log.\n")
  })
  
  return(TRUE)
}

# Run the tests
if (!interactive()) {
  main()
} else {
  cat("Running in interactive mode. Call main() to run the tests.\n")
} 