#!/usr/bin/env python3
# Office Navigation Test - Tests the sidebar navigation with executive offices
# This script tests that the sidebar navigation properly displays executive offices and
# navigates to the correct pages when clicked.

import os
import sys
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

# Set up logging
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='office_navigation_test.log',
    filemode='w'
)
logger = logging.getLogger(__name__)

# URL of the application (change this to your local or deployed URL)
APP_URL = "http://localhost:8080"

def setup_driver():
    """Set up and return a Chrome WebDriver instance."""
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Run in headless mode
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    driver = webdriver.Chrome(options=chrome_options)
    driver.maximize_window()
    return driver

def test_office_navigation():
    """Test the sidebar navigation with executive offices."""
    driver = setup_driver()
    
    try:
        # Navigate to the application
        logger.info(f"Navigating to {APP_URL}")
        driver.get(APP_URL)
        
        # Wait for the page to load
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "sidebar-panel"))
        )
        
        # Verify the title of the page
        assert "Insurance Simulation Game" in driver.title, f"Page title does not match. Got: {driver.title}"
        logger.info("Successfully loaded the application")
        
        # Check if "Executive Offices" header exists
        executive_offices_header = driver.find_element(By.XPATH, "//h3[contains(text(), 'Executive Offices')]")
        assert executive_offices_header.is_displayed(), "Executive Offices header not found"
        logger.info("Executive Offices header is displayed")
        
        # Verify all office buttons are present
        office_buttons = {
            "CEO's Office (Inbox)": "inboxBtn",
            "Chief Actuary's Office": "simCtrlBtn",
            "CRO's Office": "riskBtn",
            "CFO's Office": "auctionBtn",
            "Analytics Dashboard": "analyticsBtn"
        }
        
        for office_name, button_id in office_buttons.items():
            button = driver.find_element(By.ID, button_id)
            assert button.is_displayed(), f"{office_name} button not found"
            assert office_name in button.text, f"Button text does not contain {office_name}. Got: {button.text}"
            logger.info(f"{office_name} button is displayed and has correct text")
        
        # Test navigation to each office
        # 1. CEO's Office
        ceo_button = driver.find_element(By.ID, "inboxBtn")
        ceo_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'CEO')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "CEO's Office" in header.text, f"Navigation to CEO's Office failed. Header: {header.text}"
        logger.info("Successfully navigated to CEO's Office")
        
        # 2. Chief Actuary's Office
        actuary_button = driver.find_element(By.ID, "simCtrlBtn")
        actuary_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'Chief Actuary')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "Chief Actuary's Office" in header.text, f"Navigation to Chief Actuary's Office failed. Header: {header.text}"
        logger.info("Successfully navigated to Chief Actuary's Office")
        
        # 3. CRO's Office
        cro_button = driver.find_element(By.ID, "riskBtn")
        cro_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'CRO')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "CRO's Office" in header.text, f"Navigation to CRO's Office failed. Header: {header.text}"
        logger.info("Successfully navigated to CRO's Office")
        
        # 4. CFO's Office
        cfo_button = driver.find_element(By.ID, "auctionBtn")
        cfo_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'CFO')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "CFO's Office" in header.text, f"Navigation to CFO's Office failed. Header: {header.text}"
        logger.info("Successfully navigated to CFO's Office")
        
        # 5. Analytics Dashboard
        analytics_button = driver.find_element(By.ID, "analyticsBtn")
        analytics_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'Analytics')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "Analytics Dashboard" in header.text, f"Navigation to Analytics Dashboard failed. Header: {header.text}"
        logger.info("Successfully navigated to Analytics Dashboard")
        
        # Test the internal navigation link - from CEO's Office to CFO's Office via button
        ceo_button.click()  # Go back to CEO's Office
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "goToAuctionsBtn"))
        )
        go_to_auctions_button = driver.find_element(By.ID, "goToAuctionsBtn")
        assert "Visit CFO's Office" in go_to_auctions_button.text, f"Button text does not match. Got: {go_to_auctions_button.text}"
        go_to_auctions_button.click()
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h2[contains(text(), 'CFO')]"))
        )
        header = driver.find_element(By.XPATH, "//h2")
        assert "CFO's Office" in header.text, f"Internal navigation to CFO's Office failed. Header: {header.text}"
        logger.info("Successfully tested internal navigation from CEO's Office to CFO's Office")
        
        logger.info("All tests passed successfully!")
        return True
        
    except AssertionError as e:
        logger.error(f"Assertion error: {str(e)}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return False
    finally:
        # Take a screenshot before closing
        driver.save_screenshot("screenshots/office_navigation_test.png")
        driver.quit()

if __name__ == "__main__":
    # Make sure screenshots directory exists
    os.makedirs("screenshots", exist_ok=True)
    
    # Run the test
    test_result = test_office_navigation()
    
    if test_result:
        print("Office navigation test passed successfully!")
        sys.exit(0)
    else:
        print("Office navigation test failed. Check the log file for details.")
        sys.exit(1) 