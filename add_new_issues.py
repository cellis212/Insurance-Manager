import requests
import sys

# Usage: python add_new_issues.py <github_token>

# Check if token is provided
if len(sys.argv) < 2:
    print("Please provide your GitHub personal access token as an argument")
    print("Usage: python add_new_issues.py <github_token>")
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

# List of new issues to create
new_issues = [
    {
        "title": "Enhance Tech Tree with Visual Skill Tree Diagram",
        "body": """
# Enhance Tech Tree with Visual Skill Tree Diagram

## Description
The current Tech Tree implementation uses a basic plot to show skill connections. This issue proposes enhancing the visualization with an interactive diagram that better illustrates the relationships between skills and progression paths.

## Requirements
- Replace the simple skill connections plot with an interactive visualization
- Add connecting lines between related skills with proper styling
- Include visual indicators for skill level progression (e.g., filled nodes, color coding)
- Ensure the visualization is responsive and works on different screen sizes
- Maintain consistency with the overall dark UI theme

## Acceptance Criteria
- The visualization should clearly show skill paths and dependencies
- Users should be able to see their current level in each skill through visual indicators
- The diagram should be interactive, showing skill details on hover/click
- The visualization should be aesthetically consistent with the rest of the application
- The implementation should use appropriate R visualization libraries compatible with Shiny
        """,
        "labels": ["enhancement", "frontend", "medium-priority", "UX"]
    },
    {
        "title": "Implement Persistent Skill Storage with Database",
        "body": """
# Implement Persistent Skill Storage with Database

## Description
Currently, player skill data is stored using a file-based approach. To improve scalability, reliability, and performance, we should migrate to a proper database storage system for skill data.

## Requirements
- Replace the file-based skill storage with proper database integration (PostgreSQL or SQLite)
- Ensure skill data is properly synchronized with player profiles
- Add versioning to handle skill tree expansion and updates
- Implement proper error handling and data recovery mechanisms
- Create migration scripts to transfer existing player skill data

## Acceptance Criteria
- Player skill data should be stored persistently in a database
- Database operations should be properly encapsulated behind the existing API functions
- Performance should be equal or better than the file-based approach
- Data integrity should be maintained even when the skill tree structure changes
- The implementation should include appropriate error handling and logging
        """,
        "labels": ["enhancement", "backend", "data", "medium-priority"]
    },
    {
        "title": "Improve Selenium Test Infrastructure",
        "body": """
# Improve Selenium Test Infrastructure

## Description
We've created initial Selenium tests for the Tech Tree feature, but we need a more comprehensive testing framework that covers all modules of the application and integrates with continuous integration systems.

## Requirements
- Create a comprehensive test suite covering all app modules
- Add CI/CD integration for automated testing
- Generate test reports with screenshots and coverage metrics
- Implement test fixtures and helper functions to reduce code duplication
- Document testing approach and best practices for future development

## Acceptance Criteria
- Test coverage should include all major features of the application
- Tests should run automatically on pull requests
- Test results should be presented in a clear, visual format
- Documentation should be provided for maintaining and extending tests
- The testing framework should be stable and reliable across environments
        """,
        "labels": ["enhancement", "testing", "high-priority", "infrastructure"]
    },
    {
        "title": "Add Skills Impact Visualization",
        "body": """
# Add Skills Impact Visualization

## Description
Players need a clearer understanding of how their skill investments affect gameplay parameters. This issue proposes creating visualizations that show the impact of skills on various game metrics.

## Requirements
- Create a dashboard showing how skills affect game parameters
- Provide before/after comparisons when skills are upgraded
- Visualize potential benefits of skill investments
- Integrate with the existing analytics dashboard
- Use consistent styling and visualization approaches

## Acceptance Criteria
- Players should be able to see the direct impact of their skill investments
- The visualization should show both current effects and potential future benefits
- The UI should be intuitive and consistent with the rest of the application
- The implementation should be performant and not impact overall application responsiveness
- Tooltips and explanations should be provided for clarity
        """,
        "labels": ["enhancement", "frontend", "medium-priority", "analytics"]
    },
    {
        "title": "Implement Skill Point Award Events",
        "body": """
# Implement Skill Point Award Events

## Description
To make skill progression more engaging, we should implement a system of events and notifications that award skill points for various achievements and actions in the game.

## Requirements
- Create notification system for skill point awards
- Add special events that grant bonus skill points
- Implement challenges tied to skill point rewards
- Create a history/log of skill point awards
- Balance the skill point economy to maintain game progression

## Acceptance Criteria
- Players should receive clear notifications when they earn skill points
- Special events should occur at appropriate intervals to award additional points
- Challenges should be balanced and achievable with appropriate rewards
- The skill point award history should be accessible to players
- The awarding system should integrate with the existing game mechanics
        """,
        "labels": ["enhancement", "gameplay", "medium-priority"]
    }
]

# Create all issues
print("Creating new issues...")
for issue in new_issues:
    create_issue(issue["title"], issue["body"], issue["labels"])

print("\nDone creating GitHub issues!") 