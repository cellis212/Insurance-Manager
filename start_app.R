# Start the Shiny application for testing
# This script will start the application on port 8080

# Try to load forecast package if available
if (requireNamespace("forecast", quietly = TRUE)) {
  library(forecast)
}

options(shiny.port = 8080)
shiny::runApp("../", launch.browser = FALSE) 