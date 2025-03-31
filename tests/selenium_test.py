#!/usr/bin/env python
# Python Selenium Test for Insurance Simulation Game

import os
import sys
import time
import logging
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Configuration
TEST_URL = "http://127.0.0.1:3838"
TIMEOUT = 30  # Seconds to wait for elements
SCREENSHOT_DIR = "screenshots"

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler("python_selenium_test.log", mode='w'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Create screenshot directory if it doesn't exist
if not os.path.exists(SCREENSHOT_DIR):
    os.makedirs(SCREENSHOT_DIR)


def take_screenshot(driver, name):
    """Take a screenshot and save it to the screenshots directory"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{SCREENSHOT_DIR}/{name}_{timestamp}.png"
    driver.save_screenshot(filename)
    logger.info(f"Screenshot saved to {filename}")


def wait_for_element(driver, selector, timeout=TIMEOUT):
    """Wait for an element to be present and visible"""
    try:
        logger.info(f"Waiting for element: {selector}")
        element = WebDriverWait(driver, timeout).until(
            EC.visibility_of_element_located((By.CSS_SELECTOR, selector))
        )
        logger.info(f"Found element: {selector}")
        return element
    except TimeoutException:
        logger.error(f"Timeout waiting for element: {selector}")
        take_screenshot(driver, f"timeout_{selector.replace(' ', '_').replace('>', '_')}")
        raise


def check_app_running(driver):
    """Test if the application is running and accessible"""
    logger.info("Testing if application is accessible")
    driver.get(TEST_URL)
    
    # Take a screenshot of the initial page
    take_screenshot(driver, "initial_page")
    
    # Check if we can find the body element
    body = driver.find_element(By.TAG_NAME, "body")
    assert body is not None, "Body element not found"
    
    logger.info("Application is running and accessible")
    
    # Check for any Shiny-specific elements
    try:
        shiny_elements = driver.find_elements(By.CSS_SELECTOR, ".shiny-bound-input, .shiny-bound-output")
        logger.info(f"Found {len(shiny_elements)} Shiny elements")
    except NoSuchElementException:
        logger.warning("No Shiny-specific elements found")


def check_ui_elements(driver):
    """Test if basic UI elements are present"""
    logger.info("Checking for UI elements")
    
    # Check for common UI elements
    elements = driver.find_elements(By.CSS_SELECTOR, "div, button, input")
    element_count = len(elements)
    
    logger.info(f"Found {element_count} UI elements")
    assert element_count >= 5, "Expected at least 5 UI elements"
    
    # Check for specific Shiny elements
    try:
        inputs = driver.find_elements(By.CSS_SELECTOR, "input, select, button")
        logger.info(f"Found {len(inputs)} input elements")
        
        if len(inputs) > 0:
            logger.info(f"First input element: {inputs[0].get_attribute('outerHTML')}")
    except Exception as e:
        logger.warning(f"Error checking for input elements: {e}")


def test_navigation(driver):
    """Test navigation between different sections if possible"""
    logger.info("Testing navigation elements")
    
    # Look for navigation elements like tabs, buttons or links
    try:
        nav_elements = driver.find_elements(By.CSS_SELECTOR, "a, button, .nav-item, .tab-pane")
        logger.info(f"Found {len(nav_elements)} potential navigation elements")
        
        # If we find navigation elements, try clicking on one
        if len(nav_elements) > 0:
            for i, element in enumerate(nav_elements[:3]):  # Try the first 3 elements
                try:
                    logger.info(f"Trying to click navigation element {i}")
                    element.click()
                    time.sleep(1)  # Wait for any potential navigation
                    take_screenshot(driver, f"after_nav_click_{i}")
                    logger.info(f"Successfully clicked navigation element {i}")
                    break  # Stop after first successful click
                except Exception as e:
                    logger.warning(f"Could not click navigation element {i}: {e}")
    except Exception as e:
        logger.warning(f"Error testing navigation: {e}")


def main():
    """Main test function"""
    logger.info("=== STARTING PYTHON SELENIUM TEST ===")
    
    # Check if the app is running by making a simple HTTP request
    import requests
    try:
        response = requests.get(TEST_URL)
        if response.status_code != 200:
            logger.error(f"App is not running at {TEST_URL} - status code: {response.status_code}")
            print(f"\nERROR: Shiny app does not appear to be running at {TEST_URL}")
            print(f"Please start the app with: & 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3838)\"\n")
            return False
    except requests.exceptions.ConnectionError:
        logger.error(f"Could not connect to {TEST_URL}")
        print(f"\nERROR: Shiny app does not appear to be running at {TEST_URL}")
        print(f"Please start the app with: & 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3838)\"\n")
        return False
    
    logger.info(f"App is running at {TEST_URL}")
    
    # Initialize webdriver
    try:
        logger.info("Setting up Chrome webdriver")
        chrome_options = Options()
        chrome_options.add_argument("--headless")  # Run in headless mode
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--no-sandbox")
        
        driver = webdriver.Chrome(options=chrome_options)
        driver.set_page_load_timeout(TIMEOUT)
        logger.info("Chrome webdriver initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Chrome webdriver: {e}")
        print("\nERROR: Failed to initialize Chrome webdriver.")
        print("Please ensure Chrome is installed and webdriver is available.")
        return False
    
    try:
        # Run tests
        test_results = {
            "app_running": False,
            "ui_elements": False,
            "navigation": False
        }
        
        try:
            check_app_running(driver)
            test_results["app_running"] = True
        except Exception as e:
            logger.error(f"App running test failed: {e}")
        
        if test_results["app_running"]:
            try:
                check_ui_elements(driver)
                test_results["ui_elements"] = True
            except Exception as e:
                logger.error(f"UI elements test failed: {e}")
            
            try:
                test_navigation(driver)
                test_results["navigation"] = True
            except Exception as e:
                logger.error(f"Navigation test failed: {e}")
        
        # Print summary
        print("\n=== TEST SUMMARY ===")
        passed = sum(test_results.values())
        total = len(test_results)
        
        print(f"Passed: {passed}/{total} tests ({passed/total*100:.1f}%)")
        
        if all(test_results.values()):
            print("✅ All tests passed!")
        else:
            print("❌ Some tests failed. Check the log for details.")
            failed = [name for name, result in test_results.items() if not result]
            print(f"Failed tests: {', '.join(failed)}")
        
        logger.info("=== TEST RUN COMPLETED ===")
        
    except Exception as e:
        logger.error(f"Error during testing: {e}")
        print(f"\nError during testing: {e}")
    finally:
        # Clean up
        logger.info("Closing browser")
        driver.quit()
        logger.info("Test session ended")
        print("\nTest session ended. See python_selenium_test.log for detailed log.")
    
    return True


if __name__ == "__main__":
    main() 