# Pull Request: Implement Executive Offices in Sidebar Navigation

## Related Issue
Closes #5

## Changes Made
- Updated sidebar navigation labels to represent C-suite offices
- Changed icons to better represent each office
- Split the simulation controls into separate Chief Actuary and CRO offices
- Added new risk management UI for the CRO's Office
- Updated button references and event observers
- Updated content headings to match the office structure
- Updated internal navigation links (e.g., "Visit CFO's Office" instead of "View Auctions")
- Added documentation for the changes

## Screenshots (if applicable)
Screenshots will be added after deployment.

## Testing Performed
- Manual testing of navigation between all offices
- Verified all buttons and headings display correctly
- Verified UI functionality in each office section
- Created Selenium test script for automated testing

## Checklist
- [x] I have tested these changes locally
- [x] I have updated the documentation
- [x] I have added tests (if applicable)
- [x] All tests pass

## Additional Notes
This change enhances the roleplaying aspect of the simulation by making it clearer that the player is a CEO interacting with different C-suite executives through their respective offices.

## PR: Add Tech Tree for Skill Progression

This PR implements the Tech Tree feature as specified in issue #8, allowing players to invest in personal skill development, unlock new capabilities, and enhance their insurance operation efficiency.

### Implementation Details

1. **Tech Tree Module** (`modules/tech_tree_module.R`):
   - Created UI for a skill development system with a hierarchical structure
   - Implemented server-side logic for upgrading skills using skill points
   - Added tooltips and descriptions for each skill

2. **Backend Integration** (`backend/data_ops.R`):
   - Added functions to save and load player skills
   - Implemented skill effects calculations for simulation
   - Created functions to handle skill point awards at the end of game rounds
   - Added feature unlocking based on skill levels

3. **UI/UX Improvements**:
   - Added a "Tech Tree & Skills" button to the main navigation
   - Created styled skill cards with level indicators
   - Implemented reactive UI updates when skills are upgraded
   - Added notifications for skill upgrades

4. **CSS Styling** (`www/custom.css`):
   - Added styles for skill cards and tech tree elements
   - Implemented responsive design for different screen sizes

5. **JavaScript Support** (`www/simulation.js`):
   - Added client-side support for tech tree interactions

### Testing

- The implementation was tested using automated Selenium tests
- Manual verification was performed to ensure the UI renders correctly
- All skill upgrades function correctly and affect game mechanics

### Screenshots

- [Main Tech Tree UI](screenshots/tech-tree/main_view.png)
- [Skill Upgrade Interface](screenshots/tech-tree/skills_upgrade.png)

### Impact on Game Mechanics

This feature allows players to:
- Invest skill points earned through good performance
- Specialize in areas like operational efficiency, risk management, or actuarial science
- See tangible effects of skill improvements on game outcomes
- Create different skill builds for varied playstyles

Closes #8 