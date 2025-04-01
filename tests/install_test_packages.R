# Install required packages for testing
# This script installs all required packages for the Insurance Simulation Game

# Define the packages needed
test_packages <- c(
  "shiny",
  "shinythemes",
  "shinydashboard",
  "plotly",
  "jsonlite",
  "shinyjs",
  "forecast"
)

# Install missing packages
for (pkg in test_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste0("Installing package: ", pkg, "\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  } else {
    cat(paste0("Package already installed: ", pkg, "\n"))
  }
}

cat("All required packages installed!\n") 