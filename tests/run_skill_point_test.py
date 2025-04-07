import os
import sys
from skill_point_events_test import test_skill_point_events

if __name__ == "__main__":
    print("Running skill point events test...")
    success = test_skill_point_events()
    
    if success:
        print("✅ Test completed successfully!")
        sys.exit(0)
    else:
        print("❌ Test failed! Check skill_point_events_test.log for details.")
        sys.exit(1) 