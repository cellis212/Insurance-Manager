# Helpful AI Tips for Insurance Simulation Game

This document contains tips and solutions for common issues that may arise when working on this Insurance Simulation Game project.

## Environment Setup

1. **R Command Execution on Windows**
   - Always use `& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe'` to run R scripts in PowerShell
   - Example: `& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' -e "shiny::runApp('.', port=3838)"`

2. **Package Management with renv**
   - Install a package: `renv::install("packageName")`
   - Snapshot current packages: `renv::snapshot()`
   - Restore packages from lockfile: `renv::restore()`
   - Check status: `renv::status()`

## Common Shiny Issues

1. **Syntax Errors in UI Components**
   - Look for mismatched parentheses or unexpected `=` in setNames or named list construction
   - Example fix: Replace `c(paste0("Turn ", i) = as.character(i))` with `setNames(as.character(i), paste0("Turn ", i))`

2. **Reactive Values Not Updating**
   - Ensure reactiveValues are properly initialized
   - Make sure observe/observeEvent is used for side effects
   - Check that reactive contexts are properly established

3. **Module Communication Issues**
   - Remember Shiny modules must communicate through their return values
   - Use callModule/moduleServer pattern consistently
   - Pass namespace IDs correctly when accessing module inputs/outputs

## Selenium Testing Tips

1. **WebDriver Issues**
   - If the WebDriver fails to start, check if it matches your Chrome/Firefox version
   - You might need to specify the exact browser version: `rsDriver(browser = "chrome", chromever = "111.0.5563.64")`

2. **Element Not Found Issues**
   - Use more robust selectors (CSS or XPath)
   - Implement proper wait mechanisms with `Sys.sleep()` or custom wait functions
   - Check element visibility before interaction

3. **Element Interaction**
   - For JS-heavy elements like sliders, direct interaction may be difficult
   - Consider using executeScript to manipulate elements via JavaScript
   - Example: `remDr$executeScript("document.getElementById('mySlider').value = 75;")`

## Using RSelenium with Insurance Simulation Game

1. **Prerequisites**
   - Java must be installed (required for Selenium Server)
   - Chrome browser must be installed (or Firefox with appropriate configuration)
   - The Shiny app must be running at http://127.0.0.1:3838 before tests start

2. **Running Tests**
   - Start the Shiny app in one terminal: `& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' -e "shiny::runApp('.', port=3838)"`
   - Run the tests in another terminal: `& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/selenium_tests.R`

3. **Troubleshooting Tests**
   - If tests fail, check selenium_test_log.txt for detailed errors
   - Look at screenshots in the screenshots/ directory to see what the browser state was when a test failed
   - If you get "Could not start WebDriver" errors, make sure Java is installed and in your PATH
   - For simpler testing without RSelenium, use `manual_api_test.R` instead

4. **Session Handling**
   - RSelenium tests maintain a browser session across test cases
   - Make sure tests are organized in logical sequence as each test depends on the state from previous tests
   - Use the `client$deleteAllCookies()` command if you need to reset the session state

## Data and State Management

1. **Handling Game State**
   - Always validate state before operations (check for NULL or invalid structures)
   - Implement proper error handling around file operations
   - Use tryCatch blocks for operations that may fail

2. **File Permissions**
   - If files cannot be read/written, check folder permissions
   - Make sure data directories exist before trying to write to them
   - Use dir.create() with recursive=TRUE for nested directories

## Performance Optimization

1. **Slow Shiny App**
   - Move intensive computations outside reactive contexts when possible
   - Use reactiveVal() for single values rather than reactiveValues() lists
   - Implement caching for expensive operations with memoise

2. **Memory Usage**
   - Clear large objects when no longer needed with rm()
   - Consider using data.table instead of data.frame for large datasets
   - Use profvis package to identify memory bottlenecks

## Using Git with the Project

1. **Common Git Operations**
   - Add files: `git add .`
   - Commit changes: `git commit -m "Descriptive message"`
   - Create and checkout a new branch: `git checkout -b feature/new-feature`
   - Push changes: `git push origin branch-name`

2. **Git Issue Management**
   - Create detailed issue descriptions with clear steps to reproduce
   - Use labels to categorize issues (bug, enhancement, documentation)
   - Reference issues in commit messages using #issue-number

## Deployment Notes

1. **shinyapps.io Deployment**
   - Ensure all dependencies are in renv.lock
   - Use rsconnect::deployApp() for deployment
   - Check logs for any missing packages or errors

2. **Troubleshooting Deployment Issues**
   - Verify package versions match between development and production
   - Check for platform-specific code that might not work on Linux
   - Ensure file paths use file.path() for cross-platform compatibility
   
## UI and Design Consistency

1. **Maintaining Dark Theme**
   - Use the Darkly Shiny theme consistently
   - Ensure custom CSS in www/custom.css is applied correctly
   - Test UI components in dark mode for readability

2. **Dashboard Layout**
   - Keep the inbox-driven interface consistent
   - Maintain the Football Manager-inspired aesthetic
   - Use shinydashboard::box() for consistent panel styling 