#!/usr/bin/env python

"""
Wrapper script to run enhanced Python Selenium tests and ensure cleanup
This script ensures that any Shiny processes started during testing are properly stopped
"""

import os
import sys
import subprocess
import time
import atexit
import unittest
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

def stop_shiny_processes():
    """Stop any running Shiny processes"""
    logger.info("Stopping any running Shiny processes...")
    
    if sys.platform == 'win32':
        # On Windows, use taskkill
        try:
            subprocess.run('taskkill /F /FI "WINDOWTITLE eq R" /IM Rscript.exe', shell=True, check=False)
        except Exception as e:
            logger.warning(f"Error stopping R processes: {e}")
    else:
        # On Unix-like systems
        try:
            subprocess.run("pkill -f 'shiny::runApp'", shell=True, check=False)
        except Exception as e:
            logger.warning(f"Error stopping Shiny processes: {e}")
    
    logger.info("Cleanup complete.")

# Register cleanup function to run on exit
atexit.register(stop_shiny_processes)

def run_tests():
    """Run the enhanced Selenium tests"""
    logger.info("Starting enhanced Python Selenium tests...")
    
    all_passed = True
    
    try:
        # Import the test module
        sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        from tests.enhanced_python_selenium import EnhancedSeleniumTests
        
        # Create test suite
        test_suite = unittest.TestLoader().loadTestsFromTestCase(EnhancedSeleniumTests)
        
        # Run tests
        result = unittest.TextTestRunner(verbosity=2).run(test_suite)
        
        # Check result
        if not result.wasSuccessful():
            all_passed = False
    
    except Exception as e:
        logger.error(f"Error running enhanced Selenium tests: {e}")
        all_passed = False
    
    # Run the profile tooltip test
    logger.info("Starting profile tooltip test...")
    try:
        # Get script path
        script_dir = os.path.dirname(os.path.abspath(__file__))
        tooltip_test_path = os.path.join(script_dir, "profile_tooltip_test.py")
        
        # Run the profile tooltip test
        result = subprocess.run([sys.executable, tooltip_test_path], 
                               capture_output=True, text=True)
        
        # Log output
        if result.stdout:
            logger.info(f"Tooltip test output:\n{result.stdout}")
        if result.stderr:
            logger.error(f"Tooltip test errors:\n{result.stderr}")
        
        # Check result
        if result.returncode != 0:
            logger.error("Profile tooltip test failed")
            all_passed = False
        else:
            logger.info("Profile tooltip test passed")
    
    except Exception as e:
        logger.error(f"Error running profile tooltip test: {e}")
        all_passed = False
    
    # Run the office navigation test
    logger.info("Starting office navigation test...")
    try:
        # Get script path
        script_dir = os.path.dirname(os.path.abspath(__file__))
        office_test_path = os.path.join(script_dir, "office_navigation_test.py")
        
        # Run the office navigation test
        result = subprocess.run([sys.executable, office_test_path], 
                              capture_output=True, text=True)
        
        # Log output
        if result.stdout:
            logger.info(f"Office navigation test output:\n{result.stdout}")
        if result.stderr:
            logger.error(f"Office navigation test errors:\n{result.stderr}")
        
        # Check result
        if result.returncode != 0:
            logger.error("Office navigation test failed")
            all_passed = False
        else:
            logger.info("Office navigation test passed")
    
    except Exception as e:
        logger.error(f"Error running office navigation test: {e}")
        all_passed = False
    
    # Return True if all tests passed
    return all_passed

if __name__ == "__main__":
    # Run tests and exit with appropriate status code
    success = run_tests()
    sys.exit(0 if success else 1) 