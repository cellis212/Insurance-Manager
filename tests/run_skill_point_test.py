import sys
import os
import subprocess

# Add the current directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import the test module
from skill_point_events_test import test_skill_point_events

# Run the test and get the result
print("Running skill point events test...")
result = test_skill_point_events()

# Print the result
print("Test completed with result:", "SUCCESS" if result else "FAILURE")

# Exit with appropriate code
sys.exit(0 if result else 1) 