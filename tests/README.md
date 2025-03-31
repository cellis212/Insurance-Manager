# Enhanced Selenium Tests

This directory contains enhanced Selenium tests for the Insurance Simulation Game with improved robustness and error handling.

## Test Scripts

### Enhanced Selenium Tests

We have implemented two versions of the enhanced tests:

1. **R Version**: `enhanced_selenium_tests.R` - Comprehensive test suite implemented in R using RSelenium
2. **Python Version**: `enhanced_python_selenium.py` - The same test suite implemented in Python using selenium

Both test suites:
- Include proper timeout handling to prevent tests from getting stuck
- Implement smart port detection and auto-start for the Shiny app
- Use improved error handling and screenshots for better debugging
- Test key application functionality including:
  - Login
  - Executive profile creation
  - Inbox system
  - Simulation controls
  - Analytics dashboard
  - Auction functionality
  - Admin functionality

## Running the Tests

### Using Wrapper Scripts (Recommended)

We provide wrapper scripts that handle setup and cleanup:

**For R tests:**
```
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/run_tests.R
```

**For Python tests:**
```
python tests/run_tests.py
```

These wrapper scripts will:
1. Start the Shiny app if it's not already running
2. Run the tests
3. Clean up by stopping Shiny processes when done

### Running the Test Files Directly

Alternatively, you can run the test files directly:

**For R tests:**
```
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/enhanced_selenium_tests.R
```

**For Python tests:**
```
python tests/enhanced_python_selenium.py
```

When running directly, be aware that you may need to manually clean up Shiny processes if the tests fail.

## Test Results

Test results are logged to:
- `enhanced_selenium_test_log.txt` (R version)
- `enhanced_python_selenium.log` (Python version)

Screenshots are saved to:
- `screenshots/enhanced/` (R version)
- `screenshots/enhanced_python/` (Python version)

## Requirements

### For R Tests
- R 4.4.1 or higher
- RSelenium package
- testthat package
- jsonlite package
- wdman package
- Chrome or Firefox browser installed
- Java for Selenium server

### For Python Tests
- Python 3.6 or higher
- selenium package
- Chrome or Firefox browser installed
- ChromeDriver or GeckoDriver (installed automatically by the scripts)

## Port Configuration

Both test scripts will:
1. Check if the Shiny app is running on port 3838
2. If not found, try to start the app on port 3839
3. If port 3839 is also busy, find the next available port 