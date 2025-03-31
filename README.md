# Insurance Simulation Game

A web-based educational simulation game that teaches insurance company management through interactive decision-making and financial analysis.

![Insurance Simulation Game](www/img/logo.png)

## Overview

The Insurance Simulation Game is an interactive web application designed to teach students, newcomers, and educators about managing an insurance company. Players take on the role of a C-suite executive and make strategic decisions about premium pricing, investments, risk management, and compliance.

The game features:
- Executive profile creation with customizable backgrounds and skills
- Football Manager-inspired dark UI theme for an engaging experience
- Inbox-based navigation system simulating communications within the company
- Interactive simulation controls that affect financial outcomes
- Comprehensive analytics dashboards with performance visualization
- Turn-based multiplayer mode supporting up to 200 players
- Administrator interface for educators to control simulation parameters

## Getting Started

### Prerequisites

- R 4.4.1 or higher
- The following R packages (automatically managed with renv):
  - shiny
  - shinydashboard
  - shinythemes
  - plotly
  - jsonlite
  - shinyjs
  - and other dependencies

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/your-username/insurance-simulation-game.git
   cd insurance-simulation-game
   ```

2. Restore the renv environment:
   ```
   Rscript -e "renv::restore()"
   ```

3. Run the application:
   ```
   Rscript -e "shiny::runApp('.', port=3838)"
   ```

4. Open your browser and navigate to:
   ```
   http://localhost:3838
   ```

## Project Structure

- **app.R** - Main application file containing both UI and server components
- **backend/** - Core simulation logic and data operations
  - **simulation.R** - BLP-style utility framework for insurance demand 
  - **data_ops.R** - Functions for reading/writing data
  - **admin_ui.R** - Administrator interface for simulation control
- **modules/** - Reusable Shiny modules
  - **profile_module.R** - Executive profile creation and management
  - **inbox_module.R** - Communication system
  - **analytics_module.R** - Performance dashboards
- **data/** - Directory for game state and player decisions
- **www/** - Static assets (CSS, images)
- **tests/** - Selenium and unit tests

## Testing

The project includes two testing approaches:

### R Testing

For R-specific testing, we use testthat:

```
Rscript -e "testthat::test_dir('tests/testthat')"
```

### Python Selenium Testing

For UI testing, we use Python with Selenium:

1. Activate the Python virtual environment:
   ```
   # On Windows
   .\venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

2. Install the required Python packages:
   ```
   pip install -r requirements.txt
   ```

3. Run the Selenium tests:
   ```
   python tests/comprehensive_selenium_test.py
   ```

Note: You need to have the application running on port 3839 and a compatible browser driver installed for the tests to work properly.

## Administration

For educators and session facilitators, the admin interface can be accessed by logging in with administrator credentials. This provides:

- Control over simulation parameters
- Management of player accounts
- Ability to trigger game events
- Analysis of player decisions and performance

## Development

This project uses renv for dependency management to ensure consistent environments across installations. If you add or update packages, remember to run:

```
Rscript -e "renv::snapshot()"
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Developed as part of the Risk Management and Insurance course curriculum
- Uses the Darkly Shiny theme for UI components
- Built with R and Shiny framework 