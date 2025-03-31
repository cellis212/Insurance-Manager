#!/usr/bin/env Rscript

# Headless Selenium Test Suite for Insurance Simulation Game
# This script tests the main functionality of the application using PhantomJS
# which doesn't require Java to be installed

library(RSelenium)
library(testthat)
library(jsonlite)

# Test Configuration
TEST_URL <- "http://127.0.0.1:3838"  # URL of the locally running Shiny app
SELENIUM_TIMEOUT <- 30  # Seconds to wait for elements
SCREENSHOT_DIR <- "screenshots"  # Directory to save screenshots

# Configure logging
LOG_FILE <- "headless_test_log.txt"
log_message <- function(msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message <- paste0("[", timestamp, "] ", msg)
  cat(message, "\n")
  cat(message, "\n", file = LOG_FILE, append = TRUE)
}

# Clear previous log
if (file.exists(LOG_FILE)) {
  file.remove(LOG_FILE)
}

# Initialize PhantomJS driver directly
start_phantom_driver <- function() {
  log_message("Setting up PhantomJS directly")
  
  # Create a temporary script to start PhantomJS with webdriver
  phantom_script <- tempfile(fileext = ".R")
  write(
    "
    library(RSelenium)
    pjs <- phantomjs(port = 4444)
    Sys.sleep(5)  # Give it time to start
    
    # Keep the session open until manually interrupted
    repeat {
      Sys.sleep(1)
    }
    ",
    phantom_script
  )
  
  # Start PhantomJS in a separate R process
  system2(
    command = "C:/Program Files/R/R-4.4.1/bin/Rscript.exe",
    args = c(phantom_script),
    wait = FALSE
  )
  
  # Give it time to start
  Sys.sleep(5)
  
  # Connect to the driver
  client <- remoteDriver(
    browserName = "phantomjs",
    port = 4444L
  )
  
  # Return the client
  log_message("PhantomJS setup complete")
  return(client)
}

# Simplified test functions
check_app_running <- function(client) {
  test_that("Application is running and accessible", {
    log_message("Testing if application is accessible")
    client$navigate(TEST_URL)
    
    # Check title or any basic element
    title <- client$getTitle()
    log_message(paste("Page title:", title))
    
    # Check if we can find the body element
    body <- client$findElement("css selector", "body")
    expect_true(!is.null(body))
    
    log_message("Application is running and accessible")
  })
}

check_ui_elements <- function(client) {
  test_that("Basic UI elements are present", {
    log_message("Checking for UI elements")
    
    # Check for some basic elements that should be present in any Shiny app
    elements <- client$findElements("css selector", "div, button, input")
    element_count <- length(elements)
    
    log_message(paste("Found", element_count, "UI elements"))
    expect_gte(element_count, 5)  # We expect at least a few elements
    
    # Try to screenshot the page
    if (!dir.exists(SCREENSHOT_DIR)) {
      dir.create(SCREENSHOT_DIR, recursive = TRUE)
    }
    
    screenshot_file <- file.path(SCREENSHOT_DIR, paste0("screenshot_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
    client$screenshot(file = screenshot_file)
    log_message(paste("Saved screenshot to", screenshot_file))
    
    log_message("UI elements check passed")
  })
}

# Main test execution
main <- function() {
  cat("\nStarting Headless Selenium tests for Insurance Simulation Game\n")
  log_message("=== STARTING HEADLESS TEST RUN ===")
  
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
  
  # Start PhantomJS and get client
  client <- tryCatch({
    start_phantom_driver()
  }, error = function(e) {
    log_message(paste("Failed to start PhantomJS driver:", e$message))
    cat("\nERROR: Could not start PhantomJS driver.\n")
    return(NULL)
  })
  
  if (is.null(client)) {
    return(FALSE)
  }
  
  # Run tests
  tryCatch({
    # Try to open the session
    log_message("Opening remote browser session")
    client$open()
    log_message("Browser session opened successfully")
    
    # Run tests
    test_results <- list()
    
    test_results$app_running <- tryCatch({
      check_app_running(client)
      TRUE
    }, error = function(e) {
      log_message(paste("App running test failed:", e$message))
      FALSE
    })
    
    test_results$ui_elements <- tryCatch({
      check_ui_elements(client)
      TRUE
    }, error = function(e) {
      log_message(paste("UI elements test failed:", e$message))
      FALSE
    })
    
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
    log_message("Closing browser session")
    tryCatch({
      client$close()
    }, error = function(e) {
      log_message(paste("Error closing browser:", e$message))
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