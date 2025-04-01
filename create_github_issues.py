import os
import requests
import json
import sys

# This script creates GitHub issues for the Insurance Manager project
# Usage: python create_github_issues.py <github_token>

# Check if token is provided
if len(sys.argv) < 2:
    print("Please provide your GitHub personal access token as an argument")
    print("Usage: python create_github_issues.py <github_token>")
    sys.exit(1)

# GitHub repository information
GITHUB_TOKEN = sys.argv[1]
REPO_OWNER = "cellis212"
REPO_NAME = "Insurance-Manager"
BASE_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}"

# Set up headers for GitHub API
headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

# Function to create an issue
def create_issue(title, body, labels=None):
    url = f"{BASE_URL}/issues"
    data = {
        "title": title,
        "body": body
    }
    
    if labels:
        data["labels"] = labels
        
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        issue = response.json()
        print(f"Successfully created issue #{issue['number']}: {title}")
        return issue
    else:
        print(f"Failed to create issue. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return None

# List of feature requests to create as issues
feature_requests = [
    {
        "title": "Executive Profile Setup",
        "body": """
# Executive Profile Setup
        
## Description
Implement the guided onboarding flow where players create their executive profile by selecting:
- Secondary major (Finance, Actuarial Science, Business Analytics, etc.)
- Grad school options (MBA, MS, PhD)
- University selection (Iowa, Georgia, Florida State)

## Acceptance Criteria
- Players should be able to complete setup within 5 minutes
- All selections should impact starting state variables (capital, skills)
- Helpful tooltips explaining each choice's impact on gameplay
- Responsive design that works on tablets and desktops
- Dark UI theme consistent with the rest of the application
        """,
        "labels": ["feature", "high-priority", "frontend"]
    },
    {
        "title": "Inbox-Based Navigation System",
        "body": """
# Inbox-Based Navigation System
        
## Description
Develop an email-like inbox system where players receive communications from various C-suite roles:
- CEO messages (company direction, major events)
- CFO notifications (investment opportunities, financial updates)
- CCO alerts (compliance issues, regulatory changes)
- CAO messages (actuarial updates, pricing recommendations)
- CRO notifications (risk management issues, exposure alerts)
- Chief Actuary messages (data analysis, modeling updates)

## Acceptance Criteria
- Intuitive interface resembling an email client
- Ability to filter/sort messages by sender, date, or importance
- Messages link directly to relevant decision modules
- Notifications for new messages
- Message history is preserved for reference
- Implementation uses Shiny modules for clean code organization
        """,
        "labels": ["feature", "high-priority", "frontend", "UX"]
    },
    {
        "title": "Decision-Making Modules with Interactive Sliders",
        "body": """
# Decision-Making Modules with Interactive Sliders
        
## Description
Create interactive decision panels with sliders and input controls for:
- Premium pricing adjustments by insurance line and region
- Investment strategy allocation percentages
- Risk management approach selection
- Compliance level settings

## Acceptance Criteria
- Intuitive sliders with clear min/max values and tooltips
- Real-time feedback on slider adjustments where appropriate
- Ability to save decisions before submitting
- Visual confirmation when decisions are successfully saved
- Input validation to prevent invalid combinations
- Responsive design compatible with the dark UI theme
        """,
        "labels": ["feature", "high-priority", "frontend", "UX"]
    },
    {
        "title": "Simulation Engine for Game State Updates",
        "body": """
# Simulation Engine for Game State Updates
        
## Description
Develop the core R-based simulation engine that:
- Processes player decisions from individual files
- Implements BLP-style utility framework for market demand
- Simulates financial performance based on decisions
- Updates the game state on a yearly/weekly cycle

## Acceptance Criteria
- Efficiently processes decisions from 200+ players
- Accurate implementation of utility functions for consumer demand
- Realistic financial calculations for insurance operations
- Proper error handling for edge cases
- Well-documented code with inline comments
- Modular design for future expansion of simulation features
        """,
        "labels": ["feature", "high-priority", "backend", "simulation"]
    },
    {
        "title": "Turn-Based Synchronous Multiplayer Mode",
        "body": """
# Turn-Based Synchronous Multiplayer Mode
        
## Description
Implement the infrastructure for turn-based gameplay supporting 200+ players:
- Individual decision file storage system
- Administrator aggregation mechanism
- Synchronization of game state updates
- Player notification system for turn advancement

## Acceptance Criteria
- Reliable storage of individual player decisions
- Admin interface for triggering turn updates
- Efficient aggregation of player data
- Clear indicators of current turn/year
- Player notifications when new turns begin
- Graceful handling of players joining mid-simulation
        """,
        "labels": ["feature", "high-priority", "backend", "multiplayer"]
    },
    {
        "title": "Administrator Interface and Controls",
        "body": """
# Administrator Interface and Controls
        
## Description
Create a comprehensive administrator dashboard that allows facilitators to:
- Manage user accounts and reset passwords
- Adjust simulation parameters (market conditions, regulatory strictness)
- Trigger game events (regulatory changes, catastrophes)
- View aggregate player data and performance metrics
- Control turn advancement in multiplayer mode

## Acceptance Criteria
- Secure authentication for administrator access
- Intuitive controls for parameter adjustments
- Ability to trigger specific events for educational purposes
- Comprehensive view of player progress and performance
- Controls for resetting or restarting simulations
- Export functionality for player data and results
        """,
        "labels": ["feature", "high-priority", "backend", "admin"]
    },
    {
        "title": "Analytics Dashboards with Interactive Charts",
        "body": """
# Analytics Dashboards with Interactive Charts
        
## Description
Implement detailed analytics dashboards showing key metrics:
- Loss ratio and combined ratio visualizations
- Market share by insurance line and region
- Investment performance charts
- Risk exposure analytics
- Compliance status indicators

## Acceptance Criteria
- Interactive charts using Shiny/Plotly integration
- Drill-down capabilities for detailed analysis
- Data export functionality
- Responsive design compatible with the dark UI theme
- Performance that scales with player investment in analytics
- Clear visualization of trends over multiple game years
        """,
        "labels": ["feature", "medium-priority", "frontend", "analytics"]
    },
    {
        "title": "Tech Tree for Skill Progression",
        "body": """
# Tech Tree for Skill Progression
        
## Description
Design and implement a progression system that allows players to:
- Invest in personal skill development
- Unlock new capabilities and options
- Improve efficiency in various insurance operations
- Enhance analytical capabilities

## Acceptance Criteria
- Visual representation of available skills and dependencies
- Clear indication of costs and benefits for each upgrade
- Persistent progression across game sessions
- Integration with other game systems (analytics, decision-making)
- Balanced progression that maintains challenge
        """,
        "labels": ["feature", "medium-priority", "gameplay"]
    },
    {
        "title": "Persistent Data Storage System",
        "body": """
# Persistent Data Storage System
        
## Description
Implement a robust data storage system that:
- Saves individual player decisions and profiles
- Maintains game state history
- Supports company scaling after bankruptcy
- Enables performance analysis across multiple sessions

## Acceptance Criteria
- Reliable file-based storage for player decisions
- Efficient read/write operations
- Data integrity checks
- Backup mechanisms
- Support for exporting historical data
- Compliance with data security best practices
        """,
        "labels": ["feature", "high-priority", "backend", "data"]
    }
]

# List of issues to create
issues = [
    {
        "title": "Optimize Decision Aggregation for Large Player Count",
        "body": """
# Optimize Decision Aggregation for Large Player Count
        
## Description
The current approach to aggregating decisions from 200+ players may cause performance bottlenecks. We need to optimize this process to ensure timely turn updates.

## Steps to Reproduce
1. Run a simulation with 200+ simultaneous player connections
2. Trigger the year-end update process
3. Monitor performance and processing time

## Expected Behavior
The aggregation process should complete within 1-2 minutes regardless of player count.

## Current Behavior
Performance degrades significantly with higher player counts, potentially causing timeouts or slow updates.

## Possible Solutions
- Implement batch processing for decision aggregation
- Optimize file I/O operations
- Consider a more efficient data structure for storing decisions
        """,
        "labels": ["bug", "performance", "backend", "high-priority"]
    },
    {
        "title": "Improve Simulation Performance for Complex Utility Functions",
        "body": """
# Improve Simulation Performance for Complex Utility Functions
        
## Description
The BLP-style utility framework calculation becomes computationally expensive with many players and complex market conditions, potentially causing slow updates.

## Steps to Reproduce
1. Configure simulation with complex market conditions
2. Run with multiple insurance lines and regions
3. Trigger the year-end update

## Expected Behavior
Simulation calculations should complete within reasonable timeframes (<1 minute).

## Current Behavior
Complex simulations may take several minutes to process, causing delays in game progression.

## Possible Solutions
- Optimize the R code for utility calculations
- Consider vectorization or parallel processing
- Simplify certain calculations when precision isn't critical
- Profile the code to identify specific bottlenecks
        """,
        "labels": ["bug", "performance", "simulation", "medium-priority"]
    },
    {
        "title": "Fix Multiplayer Synchronization Issues",
        "body": """
# Fix Multiplayer Synchronization Issues
        
## Description
Players occasionally receive inconsistent game states after turn updates, leading to confusion and potential gameplay issues.

## Steps to Reproduce
1. Start a multiplayer game with 50+ players
2. Have all players submit decisions for a turn
3. Administrator triggers the turn update
4. Some players report different game states upon refresh

## Expected Behavior
All players should see identical game state information after a turn update.

## Current Behavior
Approximately 5-10% of players may see outdated or inconsistent information.

## Possible Solutions
- Implement version control for game state updates
- Add timestamps to ensure players load the latest state
- Improve the refresh mechanism for more reliable state loading
        """,
        "labels": ["bug", "multiplayer", "high-priority"]
    },
    {
        "title": "Address shinyapps.io Resource Limitations",
        "body": """
# Address shinyapps.io Resource Limitations
        
## Description
The current hosting on shinyapps.io may impose limitations on resource usage, potentially affecting performance with many concurrent users.

## Steps to Reproduce
1. Run the application with 150+ concurrent users
2. Monitor resource usage and response times
3. Observe potential timeouts or slow responses

## Expected Behavior
The application should remain responsive with up to 200 concurrent users.

## Current Behavior
Performance degradation occurs with high user counts, sometimes resulting in timeouts.

## Possible Solutions
- Optimize resource usage in the Shiny application
- Consider upgrading the shinyapps.io plan
- Explore alternative hosting options for high-volume usage
- Implement load balancing strategies
        """,
        "labels": ["bug", "infrastructure", "medium-priority"]
    },
    {
        "title": "Enhance User Onboarding and Guidance",
        "body": """
# Enhance User Onboarding and Guidance
        
## Description
Without a full in-app tutorial, some users struggle to understand the game mechanics and insurance concepts, even with tooltips.

## Steps to Reproduce
1. Create a new account and log in
2. Attempt to complete the executive profile setup
3. Navigate to the main dashboard and make initial decisions

## Expected Behavior
Users should intuitively understand what actions to take and their consequences.

## Current Behavior
New users often express confusion about certain game mechanics and insurance terminology.

## Possible Solutions
- Add a quick-start guide accessible from the dashboard
- Enhance tooltips with more detailed explanations
- Implement contextual help that appears based on user actions
- Consider a minimalist tutorial for first-time users
        """,
        "labels": ["enhancement", "UX", "medium-priority"]
    },
    {
        "title": "Improve Cross-Model AI Code Consistency",
        "body": """
# Improve Cross-Model AI Code Consistency
        
## Description
Using multiple AI models (Cursor, Claude, Gemini) has led to inconsistencies in coding style and implementation approaches across the codebase.

## Steps to Reproduce
1. Review code across different modules
2. Note variations in style, naming conventions, and implementation patterns

## Expected Behavior
Code should maintain consistent style, naming conventions, and patterns throughout.

## Current Behavior
Different modules show varying coding styles and approaches, making maintenance more difficult.

## Possible Solutions
- Establish clearer coding standards and documentation
- Implement automated style checking
- Conduct more thorough code reviews
- Create style templates for AI-assisted development
        """,
        "labels": ["technical-debt", "code-quality", "medium-priority"]
    }
]

# Create all feature requests
print("Creating feature requests...")
for feature in feature_requests:
    create_issue(feature["title"], feature["body"], feature["labels"])

# Create all issues
print("\nCreating issues...")
for issue in issues:
    create_issue(issue["title"], issue["body"], issue["labels"])

print("\nDone creating GitHub issues!") 