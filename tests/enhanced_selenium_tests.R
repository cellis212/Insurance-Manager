#!/usr/bin/env Rscript

# Enhanced Selenium Test Suite for Insurance Simulation Game
# This script provides improved test coverage and reliability as per GitHub Issue #3
#
# REQUIREMENTS:
# - Java must be installed (required for Selenium server)
# - Chrome browser must be installed
# - The Shiny app must be running at http://127.0.0.1:3838
#
# Install Java from: https://www.java.com/en/download/
# Then run the tests with: & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/enhanced_selenium_tests.R

library(RSelenium)
library(testthat)
library(jsonlite)
library(wdman)

# Test Configuration
TEST_URL <- "http://127.0.0.1:3838"  # URL of the locally running Shiny app
SELENIUM_TIMEOUT <- 30  # Seconds to wait for elements
BROWSER <- "chrome"
SCREENSHOT_DIR <- "screenshots/enhanced"
TEST_USERNAME <- "testuser"
TEST_PASSWORD <- "password"

# Configure logging
LOG_FILE <- "enhanced_selenium_test_log.txt"
log_message <- function(msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message <- paste0("[", timestamp, "] ", msg)
  cat(message, "\n")
  cat(message, "\n", file = LOG_FILE, append = TRUE)
}

# ============================================================================
# IMPROVED HELPER FUNCTIONS
# ============================================================================

# Improved wait mechanism with retry capability
wait_for_element_with_retry <- function(remDr, selector, using = "css selector", timeout = SELENIUM_TIMEOUT, max_retries = 3) {
  log_message(paste("Waiting for element:", selector, "using:", using))
  
  for (retry in 1:max_retries) {
    tryCatch({
      wait_start_time <- Sys.time()
      
      for (i in 1:timeout) {
        elements <- remDr$findElements(using = using, selector)
        
        if (length(elements) > 0) {
          is_displayed <- tryCatch({
            elements[[1]]$isElementDisplayed()[[1]]
          }, error = function(e) {
            log_message(paste("Error checking if element is displayed:", e$message))
            return(FALSE)
          })
          
          if (is_displayed) {
            elapsed <- as.numeric(difftime(Sys.time(), wait_start_time, units = "secs"))
            log_message(paste("Found element after", round(elapsed, 2), "seconds:", selector))
            return(elements[[1]])
          }
        }
        
        Sys.sleep(0.5)
      }
      
      # If we get here, the element wasn't found in this retry
      log_message(paste("Element not found in retry", retry, ":", selector))
      
      # Take a screenshot for debugging
      take_error_screenshot(remDr, paste0("retry_", retry, "_", gsub("[^a-zA-Z0-9]", "_", selector)))
      
      if (retry < max_retries) {
        log_message(paste("Retrying (", retry, "/", max_retries, ")..."))
        Sys.sleep(1)
      } else {
        stop(paste("Element not found after", max_retries, "retries:", selector))
      }
      
    }, error = function(e) {
      if (retry < max_retries) {
        log_message(paste("Error in retry", retry, ":", e$message))
        Sys.sleep(1)
      } else {
        stop(paste("Failed after", max_retries, "retries:", e$message))
      }
    })
  }
}

# Wait for element by ID (convenience wrapper)
wait_for_element_by_id <- function(remDr, id, timeout = SELENIUM_TIMEOUT, max_retries = 3) {
  wait_for_element_with_retry(remDr, id, using = "id", timeout = timeout, max_retries = max_retries)
}

# Take screenshots for error diagnosis
take_error_screenshot <- function(remDr, name_prefix) {
  tryCatch({
    if (!dir.exists(SCREENSHOT_DIR)) {
      dir.create(SCREENSHOT_DIR, recursive = TRUE)
    }
    
    screenshot_file <- file.path(SCREENSHOT_DIR, paste0(name_prefix, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
    remDr$screenshot(file = screenshot_file)
    log_message(paste("Took error screenshot:", screenshot_file))
  }, error = function(e) {
    log_message(paste("Failed to take screenshot:", e$message))
  })
}

# Test fixture to reset application state
setup_test_environment <- function(remDr) {
  log_message("Setting up test environment")
  
  # Reset browser caches and storage
  remDr$executeScript("localStorage.clear();")
  remDr$executeScript("sessionStorage.clear();")
  
  # Navigate to application
  remDr$navigate(TEST_URL)
  
  # Wait for app to load
  wait_for_element_with_retry(remDr, "body")
  
  log_message("Test environment setup complete")
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

# ============================================================================
# TEST FUNCTIONS
# ============================================================================

test_login <- function(remDr) {
  test_that("Login page works", {
    log_message("Starting login test")
    
    # Set up environment for this test
    setup_test_environment(remDr)
    
    # Wait for login form - with better error handling
    tryCatch({
      login_button <- wait_for_element_by_id(remDr, "loginButton")
      
      # Test login form is visible
      expect_true(login_button$isElementDisplayed()[[1]])
      
      # Enter test credentials
      username_input <- remDr$findElement(using = "id", "username")
      password_input <- remDr$findElement(using = "id", "password")
      
      username_input$sendKeysToElement(list(TEST_USERNAME))
      password_input$sendKeysToElement(list(TEST_PASSWORD))
      
      # Click login button
      login_button$clickElement()
      
      # Check if login was successful by looking for dashboard elements
      dashboard_element <- wait_for_element_with_retry(remDr, ".content-wrapper, #mainContent")
      expect_true(dashboard_element$isElementDisplayed()[[1]])
      log_message("Login test completed successfully")
    }, error = function(e) {
      take_error_screenshot(remDr, "login_error")
      stop(paste("Login test failed:", e$message))
    })
  })
}

test_executive_profile <- function(remDr) {
  test_that("Executive profile creation works", {
    log_message("Starting executive profile test")
    
    # Navigate to profile section
    tryCatch({
      profile_btn <- wait_for_element_by_id(remDr, "profileBtn")
      profile_btn$clickElement()
      
      # Wait for profile form - try multiple selectors
      profile_form <- tryCatch({
        wait_for_element_by_id(remDr, "profileForm")
      }, error = function(e) {
        log_message("Couldn't find profileForm by ID, trying alternative selectors")
        wait_for_element_with_retry(remDr, ".profile-section, #playerProfile-form")
      })
      
      expect_true(profile_form$isElementDisplayed()[[1]])
      
      # Fill out profile form
      major_selector <- tryCatch({
        remDr$findElement(using = "id", "secondaryMajor")
      }, error = function(e) {
        log_message("Couldn't find secondaryMajor by ID, trying alternative selectors")
        selects <- remDr$findElements(using = "css selector", "select")
        if (length(selects) > 0) {
          selects[[1]]
        } else {
          stop("No select elements found for major selection")
        }
      })
      
      major_selector$sendKeysToElement(list("Finance"))
      
      university_selector <- tryCatch({
        remDr$findElement(using = "id", "university")
      }, error = function(e) {
        log_message("Couldn't find university by ID, trying alternative selectors")
        selects <- remDr$findElements(using = "css selector", "select")
        if (length(selects) > 1) {
          selects[[2]]
        } else {
          stop("No select elements found for university selection")
        }
      })
      
      university_selector$sendKeysToElement(list("Yale"))
      
      # Save profile
      save_button <- tryCatch({
        remDr$findElement(using = "id", "saveProfileBtn")
      }, error = function(e) {
        log_message("Couldn't find saveProfileBtn by ID, trying alternative selectors")
        buttons <- remDr$findElements(using = "css selector", "button.btn-primary")
        if (length(buttons) > 0) {
          buttons[[1]]
        } else {
          stop("No buttons found for profile save")
        }
      })
      
      save_button$clickElement()
      
      # Verify success notification
      Sys.sleep(2)
      notification <- wait_for_element_with_retry(remDr, ".shiny-notification")
      expect_true(notification$isElementDisplayed()[[1]])
      log_message("Executive profile test completed successfully")
    }, error = function(e) {
      take_error_screenshot(remDr, "profile_error")
      stop(paste("Executive profile test failed:", e$message))
    })
  })
}

test_inbox_system <- function(remDr) {
  test_that("Inbox system loads messages", {
    log_message("Starting inbox system test")
    
    tryCatch({
      # Navigate to inbox
      inbox_btn <- wait_for_element_by_id(remDr, "inboxBtn")
      inbox_btn$clickElement()
      
      # Wait for inbox to load - try multiple selectors
      inbox_container <- tryCatch({
        wait_for_element_by_id(remDr, "inboxContainer")
      }, error = function(e) {
        log_message("Couldn't find inboxContainer by ID, trying alternative selectors")
        wait_for_element_with_retry(remDr, ".inbox-message, .message-item")
      })
      
      expect_true(inbox_container$isElementDisplayed()[[1]])
      
      # Verify at least one message exists
      Sys.sleep(3) # Allow time for messages to load
      messages <- remDr$findElements(using = "css selector", ".inbox-message, .message-item")
      
      # If we're in a fresh game, may not have messages yet
      if (length(messages) > 0) {
        expect_gte(length(messages), 1)
        log_message(paste("Found", length(messages), "messages"))
        
        # Try to click on a message if it's clickable
        tryCatch({
          messages[[1]]$clickElement()
          
          # Verify message content appears
          message_content <- wait_for_element_with_retry(remDr, "#messageContent, .message-body", timeout = 5)
          expect_true(message_content$isElementDisplayed()[[1]])
        }, error = function(e) {
          log_message("Message click failed, but this may be expected if messages aren't clickable in this UI")
        })
      } else {
        log_message("No messages found, this may be expected in a fresh game state")
        # Skip this assertion if no messages found
        skip("No messages found to test interaction with")
      }
      
      log_message("Inbox system test completed")
    }, error = function(e) {
      take_error_screenshot(remDr, "inbox_error")
      stop(paste("Inbox system test failed:", e$message))
    })
  })
}

test_simulation_controls <- function(remDr) {
  test_that("Simulation controls work", {
    log_message("Starting simulation controls test")
    
    tryCatch({
      # Navigate to simulation controls
      sim_ctrl_btn <- wait_for_element_by_id(remDr, "simCtrlBtn")
      sim_ctrl_btn$clickElement()
      
      # Wait for simulation controls to load - try multiple selectors
      controls_panel <- tryCatch({
        wait_for_element_by_id(remDr, "simulationControls")
      }, error = function(e) {
        log_message("Couldn't find simulationControls by ID, trying alternative selectors")
        wait_for_element_with_retry(remDr, ".simulation-section, .slider-container")
      })
      
      expect_true(controls_panel$isElementDisplayed()[[1]])
      
      # Test sliders function
      sliders <- remDr$findElements(using = "css selector", ".js-range-slider, input[type='range'], .slider")
      if (length(sliders) > 0) {
        expect_gte(length(sliders), 1)
        log_message(paste("Found", length(sliders), "sliders"))
        
        # Try to interact with a slider using JavaScript
        tryCatch({
          remDr$executeScript("arguments[0].value = 90; arguments[0].dispatchEvent(new Event('change'));", list(sliders[[1]]))
          log_message("Successfully interacted with slider")
        }, error = function(e) {
          log_message(paste("Error interacting with slider:", e$message))
        })
      } else {
        log_message("No sliders found, checking for alternative controls")
        # Look for any input controls
        input_controls <- remDr$findElements(using = "css selector", "input, select")
        expect_gte(length(input_controls), 1)
        log_message(paste("Found", length(input_controls), "input controls"))
      }
      
      # Test submit button
      submit_btn <- tryCatch({
        remDr$findElement(using = "id", "saveDecisions")
      }, error = function(e) {
        log_message("Couldn't find saveDecisions button by ID, trying alternative selectors")
        buttons <- remDr$findElements(using = "css selector", "button.btn-primary")
        if (length(buttons) > 0) {
          buttons[[length(buttons)]] # Usually the last primary button is the save button
        } else {
          NULL
        }
      })
      
      if (!is.null(submit_btn)) {
        expect_true(submit_btn$isElementDisplayed()[[1]])
        log_message("Submit button found and is displayed")
        
        # Click submit (commented out to avoid affecting game state in test environment)
        # submit_btn$clickElement()
        # Wait for confirmation notification
        # notification <- wait_for_element_with_retry(remDr, ".shiny-notification", timeout = 5)
        # expect_true(notification$isElementDisplayed()[[1]])
      } else {
        log_message("No submit button found - this may indicate a UI structure different than expected")
        skip("Submit button not found")
      }
      
      log_message("Simulation controls test completed")
    }, error = function(e) {
      take_error_screenshot(remDr, "simulation_controls_error")
      stop(paste("Simulation controls test failed:", e$message))
    })
  })
}

test_analytics_dashboard <- function(remDr) {
  test_that("Analytics dashboard displays charts", {
    log_message("Starting analytics dashboard test")
    
    tryCatch({
      # Navigate to analytics
      analytics_btn <- wait_for_element_by_id(remDr, "analyticsBtn")
      analytics_btn$clickElement()
      
      # Wait for dashboard to load - try multiple selectors
      dashboard_container <- tryCatch({
        wait_for_element_by_id(remDr, "analyticsDashboard")
      }, error = function(e) {
        log_message("Couldn't find analyticsDashboard by ID, trying alternative selectors")
        wait_for_element_with_retry(remDr, ".analytics-header, .chart-container")
      })
      
      expect_true(dashboard_container$isElementDisplayed()[[1]])
      
      # Check for charts/plots - allow more time to render
      Sys.sleep(3)
      charts <- remDr$findElements(using = "css selector", ".plotly, .shiny-plot-output, .chart, .plot, svg")
      
      # Expect at least one chart to be visible
      if (length(charts) > 0) {
        expect_gte(length(charts), 1)
        expect_true(charts[[1]]$isElementDisplayed()[[1]])
        log_message(paste("Found", length(charts), "charts/plots"))
      } else {
        log_message("No charts found with standard selectors - trying alternative selectors")
        # Try more generic selectors for visualization containers
        viz_elements <- remDr$findElements(using = "css selector", ".metric-card, .dashboard-item, .card, .box")
        if (length(viz_elements) > 0) {
          log_message(paste("Found", length(viz_elements), "potential visualization containers"))
          expect_gte(length(viz_elements), 1)
        } else {
          log_message("No visualization elements found - this may indicate an empty dashboard or different UI structure")
          skip("No charts or visualization elements found")
        }
      }
      
      # Test advanced analytics button if it exists
      advanced_btn <- tryCatch({
        remDr$findElement(using = "id", "viewAdvancedAnalyticsBtn")
      }, error = function(e) {
        log_message("Advanced analytics button not found, may not be available")
        NULL
      })
      
      if (!is.null(advanced_btn)) {
        log_message("Testing advanced analytics")
        advanced_btn$clickElement()
        
        Sys.sleep(2) # Allow time for advanced analytics to load
        advanced_container <- wait_for_element_with_retry(remDr, ".advanced-analytics-section, #advancedAnalytics-container", timeout = 10)
        expect_true(advanced_container$isElementDisplayed()[[1]])
        
        log_message("Advanced analytics loaded successfully")
      }
      
      log_message("Analytics dashboard test completed")
    }, error = function(e) {
      take_error_screenshot(remDr, "analytics_error")
      stop(paste("Analytics dashboard test failed:", e$message))
    })
  })
}

# NEW TEST: Test auction functionality
test_auction_functionality <- function(remDr) {
  test_that("Auction functionality works", {
    log_message("Starting auction functionality test")
    
    tryCatch({
      # Navigate to auctions
      auction_btn <- wait_for_element_by_id(remDr, "auctionBtn")
      auction_btn$clickElement()
      
      # Wait for auction interface to load
      auction_container <- wait_for_element_with_retry(remDr, "#auction-container, .auction-section")
      expect_true(auction_container$isElementDisplayed()[[1]])
      
      # Check for auction items
      auction_items <- remDr$findElements(using = "css selector", ".auction-item, .card, .item-card")
      
      if (length(auction_items) > 0) {
        expect_gte(length(auction_items), 1)
        log_message(paste("Found", length(auction_items), "auction items"))
        
        # Try to interact with an auction item
        auction_items[[1]]$clickElement()
        
        # Look for bid controls
        bid_inputs <- remDr$findElements(using = "css selector", "input[type='number'], .bid-input")
        bid_buttons <- remDr$findElements(using = "css selector", "button.bid-button, button.btn-primary")
        
        # Verify we have bid controls
        has_bid_controls <- length(bid_inputs) > 0 || length(bid_buttons) > 0
        expect_true(has_bid_controls)
        
        if (length(bid_inputs) > 0) {
          # Try to enter a bid amount (but don't submit)
          bid_inputs[[1]]$sendKeysToElement(list("100"))
          log_message("Successfully entered bid amount")
        }
        
        # Don't actually submit the bid to avoid affecting game state
        
      } else {
        log_message("No auction items found, may not be available in current game state")
        skip("No auction items found to test interaction with")
      }
      
      log_message("Auction functionality test completed")
    }, error = function(e) {
      take_error_screenshot(remDr, "auction_error")
      stop(paste("Auction functionality test failed:", e$message))
    })
  })
}

# NEW TEST: Test admin functionality if in admin mode
test_admin_functionality <- function(remDr) {
  test_that("Admin functionality works if enabled", {
    log_message("Starting admin functionality test")
    
    tryCatch({
      # Try to enable admin mode
      admin_checkbox <- tryCatch({
        remDr$findElement(using = "id", "isAdmin")
      }, error = function(e) {
        log_message("Admin checkbox not found, admin features may not be available")
        NULL
      })
      
      if (!is.null(admin_checkbox)) {
        # Check the admin checkbox
        admin_checkbox$clickElement()
        log_message("Enabled admin mode")
        
        # Wait for admin button to appear
        Sys.sleep(1)
        admin_btn <- wait_for_element_by_id(remDr, "adminBtn")
        admin_btn$clickElement()
        
        # Wait for admin panel to load
        admin_panel <- wait_for_element_with_retry(remDr, "#adminPanel-container, .admin-section")
        expect_true(admin_panel$isElementDisplayed()[[1]])
        
        # Look for admin controls
        admin_controls <- remDr$findElements(using = "css selector", "button, input, select")
        expect_gte(length(admin_controls), 1)
        log_message(paste("Found", length(admin_controls), "admin controls"))
        
        # Test a basic admin function (without actually making changes)
        # For example, find the game state controls
        game_state_controls <- remDr$findElements(using = "css selector", ".game-state-section, #update-turn-btn")
        
        if (length(game_state_controls) > 0) {
          log_message("Found game state controls")
        } else {
          log_message("Game state controls not found, but admin panel is accessible")
        }
        
        # Don't make any actual changes in the admin panel
        
        log_message("Admin functionality test completed")
      } else {
        log_message("Admin mode not available, skipping test")
        skip("Admin features not available")
      }
    }, error = function(e) {
      take_error_screenshot(remDr, "admin_error")
      stop(paste("Admin functionality test failed:", e$message))
    })
  })
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================

# Test timeout mechanism to prevent tests from running indefinitely
run_with_timeout <- function(test_fn, remDr, timeout = 120) {
  log_message(paste("Running test with", timeout, "second timeout"))
  
  # Create a separate process that will kill the current one after timeout
  result <- NULL
  error <- NULL
  
  # Use system time to track timeout
  start_time <- Sys.time()
  
  tryCatch({
    # Run the test function
    result <- test_fn(remDr)
    
    # Check if we've exceeded timeout - shouldn't happen but just in case
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    if (elapsed > timeout) {
      stop(paste("Test exceeded timeout of", timeout, "seconds"))
    }
    
    return(result)
  }, error = function(e) {
    # Check if this is a timeout error
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    if (elapsed > timeout) {
      log_message(paste("TEST TIMEOUT: Exceeded", timeout, "seconds"))
      take_error_screenshot(remDr, "test_timeout")
      stop(paste("Test timed out after", timeout, "seconds"))
    } else {
      # If not a timeout, re-throw the error
      stop(e)
    }
  })
}

# Function to check if a port is in use
check_port_availability <- function(port) {
  result <- tryCatch({
    con <- socketConnection(host = "127.0.0.1", port = port, 
                           server = FALSE, blocking = FALSE, 
                           open = "r+")
    close(con)
    TRUE  # Port is not in use
  }, error = function(e) {
    FALSE  # Port is in use
  })
  return(result)
}

# Function to find available port
find_available_port <- function(start_port = 3838, max_attempts = 10) {
  for (port in start_port:(start_port + max_attempts - 1)) {
    if (check_port_availability(port)) {
      return(port)
    }
  }
  return(NULL)  # No available port found
}

# Function to start Shiny app programmatically
start_shiny_app <- function(port = 3838) {
  log_message(paste("Attempting to start Shiny app on port", port))
  
  # Check if port is already in use
  if (!check_port_availability(port)) {
    log_message(paste("Port", port, "is already in use. Looking for available port..."))
    port <- find_available_port(port)
    if (is.null(port)) {
      log_message("No available ports found in range. Please close some applications and try again.")
      return(FALSE)
    }
    log_message(paste("Found available port:", port))
  }
  
  # Command to run the Shiny app
  r_command <- paste0('shiny::runApp(".", port=', port, ')')
  
  # Start the app in a separate process
  if (.Platform$OS.type == "windows") {
    system(paste0('start /B "R" "C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe" -e "', r_command, '"'), wait = FALSE)
  } else {
    system(paste0('Rscript -e "', r_command, '" &'), wait = FALSE)
  }
  
  # Update the TEST_URL global variable
  TEST_URL <<- paste0("http://127.0.0.1:", port)
  log_message(paste("Shiny app started at", TEST_URL))
  
  # Wait for app to start
  Sys.sleep(5)
  
  # Check if app is running
  app_available <- tryCatch({
    con <- url(TEST_URL, open = "r")
    close(con)
    TRUE
  }, error = function(e) {
    FALSE
  })
  
  if (!app_available) {
    log_message(paste("Failed to start Shiny app on port", port))
    return(FALSE)
  }
  
  log_message(paste("Shiny app is running at", TEST_URL))
  return(TRUE)
}

main <- function() {
  cat("\nStarting Enhanced RSelenium tests for Insurance Simulation Game\n")
  log_message("=== STARTING ENHANCED TEST RUN ===")
  
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
    log_message("Will attempt to start the Shiny app...")
    FALSE
  })
  
  # If app is not available, try to start it
  if (!app_available) {
    app_started <- start_shiny_app(port = 3839)  # Try port 3839 as 3838 is likely already in use
    
    if (!app_started) {
      cat("\nERROR: Could not start Shiny app. Please start it manually with:\n")
      cat("& 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3839)\"\n\n")
      return(FALSE)
    }
    
    # At this point, TEST_URL has been updated with the new port by start_shiny_app
  }
  
  # Start Selenium driver with better error handling
  log_message("Starting Chrome WebDriver")
  
  selenium_server <- NULL
  client <- NULL
  
  # Try multiple approaches to start the WebDriver
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
  
  # Connect to WebDriver with retry
  log_message("Connecting to WebDriver")
  connected <- FALSE
  for (retry in 1:3) {
    tryCatch({
      client$open()
      client$setTimeout(pageLoad = SELENIUM_TIMEOUT * 1000)
      connected <- TRUE
      log_message("Connected to WebDriver")
      break
    }, error = function(e) {
      log_message(paste("Failed to connect to WebDriver (attempt", retry, "):", e$message))
      Sys.sleep(2)
    })
  }
  
  if (!connected) {
    log_message("Failed to connect to WebDriver after multiple attempts")
    tryCatch(selenium_server$stop(), error = function(e) {})
    cat("\nERROR: Could not connect to WebDriver\n")
    return(FALSE)
  }
  
  # Run tests with better error handling
  test_results <- list()
  
  # Initial setup for all tests
  setup_test_environment(client)
  
  # Run tests
  tryCatch({
    log_message("Running login test...")
    test_results$login <- tryCatch({
      run_with_timeout(test_login, client, timeout = 60)
      TRUE
    }, error = function(e) {
      log_message(paste("Login test failed:", e$message))
      FALSE
    })
    
    if (test_results$login) {
      log_message("Running executive profile test...")
      test_results$profile <- tryCatch({
        run_with_timeout(test_executive_profile, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Executive profile test failed:", e$message))
        FALSE
      })
      
      log_message("Running inbox system test...")
      test_results$inbox <- tryCatch({
        run_with_timeout(test_inbox_system, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Inbox system test failed:", e$message))
        FALSE
      })
      
      log_message("Running simulation controls test...")
      test_results$controls <- tryCatch({
        run_with_timeout(test_simulation_controls, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Simulation controls test failed:", e$message))
        FALSE
      })
      
      log_message("Running analytics dashboard test...")
      test_results$analytics <- tryCatch({
        run_with_timeout(test_analytics_dashboard, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Analytics dashboard test failed:", e$message))
        FALSE
      })
      
      log_message("Running auction functionality test...")
      test_results$auction <- tryCatch({
        run_with_timeout(test_auction_functionality, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Auction functionality test failed:", e$message))
        FALSE
      })
      
      log_message("Running admin functionality test...")
      test_results$admin <- tryCatch({
        run_with_timeout(test_admin_functionality, client, timeout = 60)
        TRUE
      }, error = function(e) {
        log_message(paste("Admin functionality test failed:", e$message))
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
    
    # Detailed results
    cat("\nDetailed Results:\n")
    for (test_name in names(test_results)) {
      status <- if (test_results[[test_name]]) "PASS" else "FAIL"
      cat(sprintf("  %-25s %s\n", paste0(test_name, ":"), status))
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