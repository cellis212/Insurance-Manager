#!/usr/bin/env Rscript

# Script to install required packages for Insurance Simulation Game

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Function to install packages if not already installed
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing package:", pkg))
    install.packages(pkg)
  } else {
    message(paste("Package already installed:", pkg))
  }
}

# Core packages
core_packages <- c(
  "shiny",
  "shinydashboard",
  "shinythemes",
  "plotly",
  "jsonlite",
  "shinyjs",
  "DT"
)

# Testing packages
testing_packages <- c(
  "testthat",
  "RSelenium",
  "wdman",
  "httr"
)

# Development and dependency management
dev_packages <- c(
  "renv",
  "remotes",
  "devtools"
)

# Install all packages
message("Installing core packages...")
for (pkg in core_packages) {
  install_if_missing(pkg)
}

message("\nInstalling testing packages...")
for (pkg in testing_packages) {
  install_if_missing(pkg)
}

message("\nInstalling development packages...")
for (pkg in dev_packages) {
  install_if_missing(pkg)
}

message("\nAll packages installed successfully!")
message("Next, initialize renv with: renv::init()")
message("After changes, use: renv::snapshot() to save package state") 