# Contributing to Insurance Simulation Game

Thank you for your interest in contributing to the Insurance Simulation Game project! This document provides guidelines and instructions to help you set up your development environment and contribute effectively.

## Setting Up Your Development Environment

### GitHub Authentication

1. Copy `sample.env` to `.env`
2. Replace `your_github_token_here` with your personal GitHub token
3. Generate a token at https://github.com/settings/tokens with the following scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
   - `read:org` (Read organization information)

The GitHub token is used for:
- Running cursor-tools GitHub commands
- Creating pull requests and issues
- Managing repository operations

### R Environment Setup

1. Install R 4.4.1 or later
2. Install required R packages:
   ```R
   install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'plotly'))
   ```

### Running the Application

Run the Shiny application with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' -e "shiny::runApp(launch.browser = TRUE)"
```

## Development Workflow

1. Create a new branch for your feature or fix
2. Implement your changes
3. Write/update tests to verify your changes
4. Submit a pull request

## Testing

For details on testing the application, see the R and Shiny Testing Guidelines in the `.cursorrules` file.

## Code Style

- Follow the tidyverse style guide for R code
- Use meaningful variable and function names
- Include comments for complex logic
- Ensure all user-facing text is clear and concise

## Commit Messages

Write clear, descriptive commit messages:

```
[feature/fix/docs]: Brief description

Detailed explanation of what changed and why
```

## Pull Requests

- Link your PR to any related issues
- Include screenshots for UI changes
- Ensure tests pass
- Request review from project maintainers

## Questions?

If you have questions or need help, please open an issue with the label "question". 