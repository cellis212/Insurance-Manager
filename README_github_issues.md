# GitHub Issues Management for Insurance Simulation Game

This README explains how to use the included Python script to create GitHub issues for tracking features and bugs in the Insurance Simulation Game project.

## Prerequisites

Before using the script, you'll need:

1. Python installed on your system
2. The `requests` library (`pip install requests`)
3. A GitHub Personal Access Token with permission to create issues

## Getting a GitHub Personal Access Token (PAT)

1. Go to your GitHub account settings
2. Navigate to Developer Settings → Personal Access Tokens → Fine-grained tokens
3. Click "Generate new token"
4. Give it a name like "Insurance Manager Issue Creation"
5. Set the expiration as needed
6. Select the repository access to "Only select repositories" and choose the "Insurance-Manager" repo
7. Under repository permissions, grant "Issues: Read and Write" access
8. Click "Generate token" and copy the token to a secure location

## Using the Script

The script (`create_github_issues.py`) will create a set of predefined feature requests and issues on your GitHub repository.

To run the script:

```bash
python create_github_issues.py YOUR_GITHUB_TOKEN
```

Replace `YOUR_GITHUB_TOKEN` with the personal access token you created.

## What the Script Creates

The script will create:

1. **Feature Requests (9)** - These correspond to major features from the project requirements:
   - Executive Profile Setup
   - Inbox-Based Navigation System
   - Decision-Making Modules with Interactive Sliders
   - Simulation Engine for Game State Updates
   - Turn-Based Synchronous Multiplayer Mode
   - Administrator Interface and Controls
   - Analytics Dashboards with Interactive Charts
   - Tech Tree for Skill Progression
   - Persistent Data Storage System

2. **Issues (6)** - These track potential problems and challenges identified in the project:
   - Optimize Decision Aggregation for Large Player Count
   - Improve Simulation Performance for Complex Utility Functions
   - Fix Multiplayer Synchronization Issues
   - Address shinyapps.io Resource Limitations
   - Enhance User Onboarding and Guidance
   - Improve Cross-Model AI Code Consistency

## Labels Used

The issues include the following labels to help with organization:

- **Priority levels**: high-priority, medium-priority
- **Type tags**: feature, bug, enhancement, technical-debt
- **Component tags**: frontend, backend, UX, performance, simulation, multiplayer, admin, data, infrastructure, code-quality, gameplay

## Customizing Issues

If you want to customize the issues before creating them:

1. Open `create_github_issues.py` in a text editor
2. Modify the `feature_requests` and `issues` lists as needed
3. Save the file and run it again with your GitHub token

## Tracking Progress

Once the issues are created, you can track project progress in several ways:

1. Use the GitHub Projects feature to create a Kanban board
2. Filter issues by labels to focus on specific areas
3. Assign issues to team members
4. Create milestones to group related issues together 