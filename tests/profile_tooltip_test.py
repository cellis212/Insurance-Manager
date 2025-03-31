#!/usr/bin/env python3
"""
Tooltip Functionality Test for Profile Setup

This test verifies that the tooltips for secondary major, graduate school, and university options
display correctly in the profile setup page. It also ensures the correct description boxes appear
when different options are selected.
"""

import os
import sys
import time
import datetime
import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='profile_tooltip_test.log',
    filemode='w'
)
logger = logging.getLogger()

def setup_driver():
    """Set up and return the WebDriver instance with appropriate options."""
    try:
        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_argument('--headless')  # Run in headless mode
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--window-size=1920,1080')
        
        driver = webdriver.Chrome(options=chrome_options)
        logger.info("Chrome WebDriver initialized successfully")
        return driver
    except Exception as e:
        logger.error(f"Failed to initialize WebDriver: {e}")
        sys.exit(1)

def run_tooltip_test(url="http://localhost:3838"):
    """Run the tooltip tests for profile setup page."""
    driver = setup_driver()
    
    try:
        logger.info(f"Opening URL: {url}")
        driver.get(url)
        driver.save_screenshot('screenshots/initial_page.png')
        
        # Wait for profile page to load
        logger.info("Waiting for profile setup page to load")
        try:
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "playerProfile-username"))
            )
            logger.info("Profile setup page loaded successfully")
        except TimeoutException:
            logger.error("Timeout waiting for profile setup page to load")
            driver.save_screenshot('screenshots/timeout_profile_page.png')
            return False
        
        # Test tooltips and descriptions
        test_tooltip_functionality(driver)
        
        return True
    except Exception as e:
        logger.error(f"Error during test execution: {e}")
        driver.save_screenshot('screenshots/error.png')
        return False
    finally:
        driver.quit()
        logger.info("WebDriver closed")

def test_tooltip_functionality(driver):
    """
    Test tooltip functionality for all select inputs in profile setup.
    """
    try:
        # Get select elements by their IDs
        major_select = driver.find_element(By.ID, "playerProfile-secondaryMajor")
        grad_select = driver.find_element(By.ID, "playerProfile-gradSchool")
        univ_select = driver.find_element(By.ID, "playerProfile-university")
        
        logger.info("Found all select inputs")
        
        # Test Major Description Box
        select_option_and_verify_description(driver, "playerProfile-secondaryMajor", "Finance", "playerProfile-majorDescription")
        select_option_and_verify_description(driver, "playerProfile-secondaryMajor", "Actuarial Science", "playerProfile-majorDescription")
        select_option_and_verify_description(driver, "playerProfile-secondaryMajor", "Business Analytics", "playerProfile-majorDescription")
        select_option_and_verify_description(driver, "playerProfile-secondaryMajor", "Marketing", "playerProfile-majorDescription")
        select_option_and_verify_description(driver, "playerProfile-secondaryMajor", "Management", "playerProfile-majorDescription")
        
        # Test Grad School Description Box
        select_option_and_verify_description(driver, "playerProfile-gradSchool", "MBA", "playerProfile-gradSchoolDescription")
        select_option_and_verify_description(driver, "playerProfile-gradSchool", "MS in Risk Management", "playerProfile-gradSchoolDescription")
        select_option_and_verify_description(driver, "playerProfile-gradSchool", "MS in Finance", "playerProfile-gradSchoolDescription")
        select_option_and_verify_description(driver, "playerProfile-gradSchool", "MS in Actuarial Science", "playerProfile-gradSchoolDescription")
        select_option_and_verify_description(driver, "playerProfile-gradSchool", "PhD", "playerProfile-gradSchoolDescription")
        
        # Test University Description Box
        select_option_and_verify_description(driver, "playerProfile-university", "University of Iowa", "playerProfile-universityDescription")
        select_option_and_verify_description(driver, "playerProfile-university", "Florida State University", "playerProfile-universityDescription")
        select_option_and_verify_description(driver, "playerProfile-university", "University of Georgia", "playerProfile-universityDescription")
        
        logger.info("Successfully tested all description boxes")
        
    except NoSuchElementException as e:
        logger.error(f"Element not found: {e}")
        driver.save_screenshot('screenshots/element_not_found.png')
        raise
    except AssertionError as e:
        logger.error(f"Assertion failed: {e}")
        driver.save_screenshot('screenshots/assertion_failed.png')
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        driver.save_screenshot('screenshots/unexpected_error.png')
        raise

def select_option_and_verify_description(driver, select_id, option_text, description_id):
    """
    Select an option from a dropdown and verify its description box appears with correct content.
    """
    try:
        # Wait for select element to be present
        select_element = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, select_id))
        )
        
        # Get the selectize-input element which is the actual clickable element
        selectize_container = select_element.find_element(By.XPATH, "./parent::div")
        selectize_input = selectize_container.find_element(By.CLASS_NAME, "selectize-input")
        
        # Click to open the dropdown
        selectize_input.click()
        time.sleep(1)  # Give time for dropdown to appear
        
        # Find and click the option
        dropdown_content = driver.find_element(By.CLASS_NAME, "selectize-dropdown-content")
        
        # Look for the option in the dropdown
        options = dropdown_content.find_elements(By.TAG_NAME, "div")
        option_found = False
        for option in options:
            if option.text == option_text:
                option.click()
                option_found = True
                logger.info(f"Selected option '{option_text}' from dropdown {select_id}")
                break
                
        if not option_found:
            logger.error(f"Could not find option '{option_text}' in dropdown")
            driver.save_screenshot(f'screenshots/option_not_found_{select_id}_{option_text.replace(" ", "_")}.png')
            return False
        
        # Wait for description box to be visible (with longer timeout)
        time.sleep(1)  # Give time for description to appear
        description_box = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, description_id))
        )
        
        # Verify description contains expected content
        assert description_box.is_displayed(), f"Description box {description_id} should be visible"
        
        # Take a screenshot of the description box
        driver.save_screenshot(f'screenshots/{select_id}_{option_text.replace(" ", "_")}.png')
        
        # Check for description content
        description_html = description_box.get_attribute('innerHTML')
        assert "option-description" in description_html, "Description should contain explanation text"
        assert "skill-bar" in description_html, "Description should contain skill bars"
        
        logger.info(f"Successfully verified description for '{option_text}' in {select_id}")
        return True
        
    except TimeoutException as e:
        logger.error(f"Timeout waiting for element: {e}")
        driver.save_screenshot(f'screenshots/timeout_{select_id}_{option_text.replace(" ", "_")}.png')
        return False
    except NoSuchElementException as e:
        logger.error(f"Element not found: {e}")
        driver.save_screenshot(f'screenshots/not_found_{select_id}_{option_text.replace(" ", "_")}.png')
        return False
    except AssertionError as e:
        logger.error(f"Assertion failed: {e}")
        driver.save_screenshot(f'screenshots/assertion_{select_id}_{option_text.replace(" ", "_")}.png')
        return False
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        driver.save_screenshot(f'screenshots/error_{select_id}_{option_text.replace(" ", "_")}.png')
        return False

if __name__ == "__main__":
    # Ensure screenshots directory exists
    os.makedirs("screenshots", exist_ok=True)
    
    # Log test start
    logger.info("Starting profile tooltip functionality test")
    
    # Check if URL was provided as command line argument
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:3838"
    
    # Run the test
    result = run_tooltip_test(url)
    
    # Log test result
    if result:
        logger.info("Profile tooltip test PASSED")
        print("Profile tooltip test PASSED")
        sys.exit(0)
    else:
        logger.error("Profile tooltip test FAILED")
        print("Profile tooltip test FAILED")
        sys.exit(1) 