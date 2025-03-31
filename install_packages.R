# Insurance Simulation Game - Package Installation Script
# Run this script to install all required packages

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# List of required packages
required_packages <- c(
  "shiny",           # Core Shiny framework
  "shinythemes",     # For Darkly theme
  "shinydashboard",  # For dashboard layout components
  "plotly",          # For interactive visualizations
  "jsonlite",        # For handling JSON data
  "shinyjs",         # For JavaScript functionality in Shiny
  "digest",          # For generating hash IDs
  "DT"               # For interactive tables
)

# Function to check and install packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Installing package: %s\n", pkg))
    install.packages(pkg)
  } else {
    cat(sprintf("Package already installed: %s\n", pkg))
  }
}

# Install all required packages
cat("Checking and installing required packages...\n")
for (pkg in required_packages) {
  install_if_missing(pkg)
}

# Verify all packages can be loaded
cat("\nVerifying package installation...\n")
success <- TRUE
for (pkg in required_packages) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat(sprintf("Successfully loaded: %s\n", pkg))
  }, error = function(e) {
    cat(sprintf("Error loading package %s: %s\n", pkg, e$message))
    success <- FALSE
  })
}

# Final status message
if (success) {
  cat("\nAll packages installed and loaded successfully.\n")
  cat("You can now run the Insurance Simulation Game using 'shiny::runApp()'\n")
} else {
  cat("\nSome packages could not be loaded. Please check the error messages above.\n")
} 