# Start the Shiny application for testing
# This script will start the application on port 8080

options(shiny.port = 8080)
shiny::runApp("../", launch.browser = FALSE) 