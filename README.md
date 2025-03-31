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

## Recent Changes

### Version Updates

#### 2025-03-31 Update
- **Added Interactive Tooltips**: Added detailed tooltips to the executive profile setup page that show how each choice (major, graduate school, university) affects player skills and abilities. When selecting different options, users now see full explanations with visual skill bars.
- **University List Correction**: Updated the university options to specifically include only University of Iowa, Florida State University, and University of Georgia to match the simulation's regional focus.
- **New Tooltip Testing**: Added a comprehensive Selenium test (`profile_tooltip_test.py`) to verify tooltip functionality and ensure descriptions display correctly.

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

The project includes multiple testing approaches:

### R Testing

For R-specific testing, we use testthat:

```
Rscript -e "testthat::test_dir('tests/testthat')"
```

### Enhanced Selenium Tests

For more robust UI testing, we've implemented enhanced Selenium test suites in both R and Python with improved timeout handling:

**R Version (recommended if you have Java installed):**
```
# Using wrapper script (handles cleanup automatically)
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/run_tests.R

# Or run test directly
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' tests/enhanced_selenium_tests.R
```

**Python Version (recommended if you don't have Java):**
```
# Using wrapper script (handles cleanup automatically)
python tests/run_tests.py

# Or run test directly
python tests/enhanced_python_selenium.py
```

**Tooltip Testing:**
```
# Test tooltip functionality specifically
python tests/profile_tooltip_test.py
```

The enhanced tests include:
- Automatic timeout handling to prevent tests from getting stuck
- Smart port detection and app auto-start
- Improved screenshots and error reporting
- See `tests/README.md` for more details

### Legacy Selenium Testing

For basic UI testing, we also maintain the original Selenium tests:

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