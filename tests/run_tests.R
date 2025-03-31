#!/usr/bin/env Rscript

# Wrapper script to run enhanced Selenium tests and handle cleanup
# This script ensures that any Shiny processes started during testing are properly stopped when tests complete

# Function to kill Shiny processes
stop_shiny_processes <- function() {
  cat("Stopping any running Shiny processes...\n")
  
  if (.Platform$OS.type == "windows") {
    # On Windows, find and kill R processes running Shiny
    system('taskkill /F /FI "WINDOWTITLE eq R" /IM Rscript.exe', show.output.on.console = FALSE)
  } else {
    # On Unix-like systems, use ps and grep to find and kill processes
    system("pkill -f 'shiny::runApp'", ignore.stderr = TRUE, ignore.stdout = TRUE)
  }
  
  cat("Cleanup complete.\n")
}

# Run the enhanced Selenium tests
run_tests <- function() {
  cat("Starting enhanced Selenium tests...\n")
  
  # Source the test script
  result <- tryCatch({
    source("tests/enhanced_selenium_tests.R")
    main()
  }, error = function(e) {
    cat("Error during test execution:", e$message, "\n")
    FALSE
  }, finally = {
    # Always stop Shiny processes when done
    stop_shiny_processes()
  })
  
  return(result)
}

# Run the tests
run_tests() 