# Executive Offices Navigation Update

## Overview

This document describes the changes made to implement GitHub issue #5: "The side tabs should represent offices". The sidebar navigation in the Insurance Simulation Game has been updated to represent different executive offices rather than generic tabs. This change enhances the roleplaying experience, making it clearer that the player is acting as a CEO managing different aspects of an insurance company through interactions with various C-suite executives.

## Changes Made

### 1. Updated Sidebar Navigation

The sidebar navigation buttons have been renamed and reorganized to represent different executive offices:

- **CEO's Office (Inbox)** - Replaces the generic "Inbox" tab, serving as the central communication hub
- **Chief Actuary's Office** - Replaces "Simulation Controls", focusing on premium pricing decisions
- **CRO's Office** - New section for risk management and derivatives strategy
- **CFO's Office** - Replaces "Auctions" tab, focusing on investments and asset management
- **Analytics Dashboard** - Retained as a general view for performance metrics

### 2. Updated Icons

Icons were updated to better represent each office:

- **CEO's Office** - Briefcase icon (was an envelope)
- **Chief Actuary's Office** - Calculator icon (was sliders)
- **CRO's Office** - Shield-alt icon (new)
- **CFO's Office** - Chart-line icon (was gavel)
- **Analytics Dashboard** - Chart-bar icon (was chart-line)

### 3. Content Updates

Each office's UI was updated with appropriate headings and content descriptions:

- **CEO's Office** - Main inbox showing messages from C-suite executives and external stakeholders
- **Chief Actuary's Office** - Premium pricing interface for different insurance lines
- **CRO's Office** - Risk management controls including reinsurance levels and regional risk exposure
- **CFO's Office** - Investment strategy and auction participation
- **Analytics Dashboard** - Performance metrics and visualizations

### 4. Functional Changes

- Separated the premium pricing controls (now in Chief Actuary's Office) from investment controls (now in CFO's Office)
- Added new risk management controls in the CRO's Office
- Updated button labels to match the office metaphor (e.g., "Visit CFO's Office" instead of "View Auctions")

## Implementation Details

The changes were implemented by modifying the app.R file, specifically:

1. Updated the sidebar navigation buttons in the UI definition
2. Created a new `riskManagementUI()` function for the CRO's Office
3. Split the previous `simulationControlsUI()` function into separate sections for the Chief Actuary's Office and the CFO's Office
4. Updated button and function references in event observers to match the new structure

## Testing

The changes have been tested to ensure:

1. All navigation buttons display correctly with the proper labels and icons
2. Navigation between different offices works correctly
3. The UI content for each office is displayed appropriately
4. Internal navigation links (e.g., from CEO's Office to CFO's Office) work correctly

## Manual Testing Guide

To manually test the executive offices navigation:

1. Start the application and verify that the sidebar displays "Executive Offices" as the heading
2. Check that all five office buttons are visible with the proper names and icons
3. Click each button and verify that the appropriate content appears in the main panel
4. In the CEO's Office (Inbox), click the "Visit CFO's Office" button and verify that it navigates to the CFO's Office
5. Verify that the office title appears in the main panel heading when each office is selected

## Future Improvements

Potential future improvements could include:

1. Adding unique office backgrounds or themes for each C-suite office
2. Expanding the CRO functionality with more detailed risk management tools
3. Adding office-specific notifications or alerts
4. Implementing personalized messaging from each executive based on game events

## Related Issues

- Issue #5: The side tabs should represent offices 