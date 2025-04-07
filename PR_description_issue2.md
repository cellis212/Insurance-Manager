# Add Info on Major Choice Impact and Skill Updates

This PR addresses Issue #2 by verifying and documenting the existing implementation of major choice descriptions and skill impact visualizations.

## Features

- Verified that selecting different majors displays appropriate descriptions
- Verified that skill impact visualizations update correctly based on major selection
- Added Selenium test script to verify this functionality

## Implementation Details

The functionality was already implemented in `modules/profile_module.R`, with:
- Descriptive text for each major choice that explains its impact on skills
- Visual skill bars that dynamically update when a different major is selected
- Preview Impact button to see the combined effect of all choices

## Testing

Automated testing has been added through a Selenium script that:
1. Opens the profile setup page
2. Verifies the default major (Finance) shows correct description and skill bars
3. Tests changing to other majors and verifies their descriptions and skill impacts
4. Tests the Preview Impact button functionality
5. Captures screenshots at each step for verification

## Screenshots

Screenshots demonstrating the functionality can be found in the `screenshots` directory after running the test.

Closes #2 