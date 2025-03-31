# Insurance Simulation Game

An interactive educational web application designed to teach the principles of insurance company management through a realistic, turn-based simulation experience.

## Overview

The Insurance Simulation Game provides a hands-on learning environment for students, newcomers, and educators in the insurance and finance fields. Players take on the role of an insurance company executive, making critical decisions about premium pricing, investments, risk management, and compliance.

The simulation is built around a realistic BLP-style utility framework that models consumer behavior and market dynamics based on academic finance theories. This creates an engaging educational experience that demonstrates the real-world impact of strategic decisions on insurance company performance.

## Key Features

- **Executive Profile Creation**: Players begin by setting up an executive profile, selecting their secondary major, graduate school, and university preferences.
- **Inbox-Based Navigation**: A central communication hub where players receive notifications and guidance from various C-suite roles.
- **Decision-Making via Sliders**: Interactive sliders and input controls allow players to adjust premium rates, set investment strategies, and manage risk across multiple insurance lines.
- **Comprehensive Analytics**: Detailed dashboards display key performance metrics such as loss ratio, combined ratio, and market share through interactive visualizations.
- **Turn-Based Multiplayer**: Support for up to 200 players in a synchronous, turn-based environment where decisions are aggregated by an administrator.
- **Administrator Interface**: Facilitators can customize simulation parameters, trigger game events, and manage the overall game state.

## Technical Stack

- **Frontend**: R Shiny with a dark UI theme (Darkly Shiny theme)
- **Backend**: R for simulation logic and data processing
- **Hosting**: Deployed on shinyapps.io
- **Data Storage**: Individual player decisions stored in files for aggregation

## Getting Started

### Prerequisites

- R 4.4.1 or newer
- Required R packages:
  - shiny
  - shinythemes
  - shinydashboard
  - plotly

### Installation

1. Clone this repository:
```
git clone https://github.com/yourusername/insurance-simulation-game.git
```

2. Install the required R packages:
```R
install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'plotly'))
```

3. Run the application locally:
```R
shiny::runApp()
```

### Directory Structure

- `app.R`: Main application file
- `backend/`: Simulation logic and backend functions
- `data/`: Storage for player decisions and game state
- `modules/`: Reusable Shiny modules
- `www/`: Static assets (CSS, images, etc.)

## Deployment

The application is designed to be deployed on [shinyapps.io](https://www.shinyapps.io/). Follow these steps to deploy:

1. Create an account on shinyapps.io
2. Install the rsconnect package: `install.packages('rsconnect')`
3. Configure your account credentials
4. Deploy using the RStudio interface or the command line

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Project designed for educational purposes in insurance and risk management courses
- Built with modern R and Shiny frameworks
- Simulation models based on academic finance and insurance principles 