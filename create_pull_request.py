import requests
import sys

# Usage: python create_pull_request.py <github_token>

# Check if token is provided
if len(sys.argv) < 2:
    print("Please provide your GitHub personal access token as an argument")
    print("Usage: python create_pull_request.py <github_token>")
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

# Read PR description from file
try:
    with open("PR_description.md", "r") as f:
        pr_description = f.read()
except:
    pr_description = """
# Tech Tree for Skill Progression

This PR implements a comprehensive Tech Tree feature that allows players to invest in personal skill development, unlock new capabilities, and enhance their insurance operation efficiency.

## Features

- Skill card UI with upgrade options
- Backend integration for skill effects
- Skill point awarding system
- Integration with simulation mechanics
- CSS styling for skill levels and cards
- JavaScript support for UI updates

## Testing

The implementation includes Selenium-based automated tests to verify the tech tree functionality.

Closes #8
"""

# Create the pull request
def create_pull_request():
    url = f"{BASE_URL}/pulls"
    data = {
        "title": "Add Tech Tree for Skill Progression",
        "body": pr_description,
        "head": "feature/tech-tree",
        "base": "master"
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        pr = response.json()
        print(f"Successfully created PR #{pr['number']}: {pr['html_url']}")
        return pr
    else:
        print(f"Failed to create PR. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return None

if __name__ == "__main__":
    print("Creating pull request for the Tech Tree feature...")
    create_pull_request() 