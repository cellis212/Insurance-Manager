#!/usr/bin/env Rscript

# Manual API Test Script for Insurance Simulation Game
# This is a simpler alternative to the Selenium tests that uses HTTP requests to test
# the API endpoints directly

library(httr)
library(jsonlite)

# Configuration
API_BASE_URL <- "http://127.0.0.1:3838"
TEST_LOG_FILE <- "manual_api_test_log.txt"

# Setup logging
log_message <- function(msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message <- paste0("[", timestamp, "] ", msg)
  cat(message, "\n")
  cat(message, "\n", file = TEST_LOG_FILE, append = TRUE)
}

# Clear previous log
if (file.exists(TEST_LOG_FILE)) {
  file.remove(TEST_LOG_FILE)
}

log_message("=== Starting Manual API Test ===")

# Test 1: Check if application is running
log_message("Test 1: Checking if app is running")
app_running <- tryCatch({
  response <- GET(API_BASE_URL)
  status <- status_code(response)
  
  if (status == 200) {
    log_message("  SUCCESS: Application is running!")
    TRUE
  } else {
    log_message(paste("  FAIL: Unexpected status code:", status))
    FALSE
  }
}, error = function(e) {
  log_message(paste("  FAIL: Error connecting to application:", e$message))
  FALSE
})

if (!app_running) {
  log_message("Cannot proceed with tests. Please start the application first.")
  log_message("Run: & 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3838)\"")
  stop("Application not running. See log for details.")
}

# Test 2: Check login functionality
# Note: Since Shiny uses sessions and doesn't have typical REST endpoints,
# we can only check that the login page loads, not actually submit login credentials
# without using a full web browser
log_message("Test 2: Checking login page")
login_page <- tryCatch({
  response <- GET(API_BASE_URL)
  html_content <- content(response, "text")
  
  if (grepl("loginButton", html_content, fixed = TRUE) || 
      grepl("username", html_content, fixed = TRUE) || 
      grepl("password", html_content, fixed = TRUE)) {
    log_message("  SUCCESS: Login elements detected in HTML")
    TRUE
  } else {
    log_message("  FAIL: Login elements not found in HTML")
    FALSE
  }
}, error = function(e) {
  log_message(paste("  FAIL: Error checking login page:", e$message))
  FALSE
})

# Test 3: Basic application structure
log_message("Test 3: Checking application structure")
app_structure <- tryCatch({
  response <- GET(API_BASE_URL)
  html_content <- content(response, "text")
  
  # Check for key elements that should be in the HTML
  checks <- list(
    "Shiny" = grepl("shiny", html_content, ignore.case = TRUE),
    "JavaScript" = grepl("<script", html_content, fixed = TRUE),
    "Stylesheet" = grepl("<link", html_content, fixed = TRUE)
  )
  
  passing <- all(unlist(checks))
  
  if (passing) {
    log_message("  SUCCESS: Basic application structure verified")
    log_message(paste("    Found:", paste(names(checks)[unlist(checks)], collapse=", ")))
    TRUE
  } else {
    log_message("  FAIL: Some elements missing from application structure")
    log_message(paste("    Missing:", paste(names(checks)[!unlist(checks)], collapse=", ")))
    FALSE
  }
}, error = function(e) {
  log_message(paste("  FAIL: Error checking application structure:", e$message))
  FALSE
})

# Test Summary
log_message("\n=== Manual API Test Summary ===")
tests <- c(app_running, login_page, app_structure)
pass_count <- sum(tests)
total_count <- length(tests)

log_message(paste("Passed:", pass_count, "/", total_count, "tests", 
                 sprintf("(%.1f%%)", pass_count/total_count*100)))

if (all(tests)) {
  log_message("✅ All tests passed!")
} else {
  log_message("❌ Some tests failed. See log for details.")
}

log_message("=== Manual API Test Complete ===")

# Print summary to console
cat("\n=== Manual API Test Summary ===\n")
cat(sprintf("Passed: %d/%d tests (%.1f%%)\n", 
            pass_count, total_count, pass_count/total_count*100))

if (all(tests)) {
  cat("✅ All tests passed!\n")
} else {
  cat("❌ Some tests failed. See log for details.\n")
}

cat("See", TEST_LOG_FILE, "for detailed log.\n") 