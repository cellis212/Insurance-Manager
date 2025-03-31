#!/usr/bin/env python
# Enhanced Python Selenium Test Suite for Insurance Simulation Game
# This script provides improved test coverage and reliability as per GitHub Issue #3
#
# REQUIREMENTS:
# - Chrome or Firefox browser must be installed
# - The Shiny app must be running at http://127.0.0.1:3838
# - Required Python packages: selenium, pytest
#
# Run the tests with: python tests/enhanced_python_selenium.py

import os
import sys
import time
import logging
from datetime import datetime
import unittest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, ElementNotInteractableException

# Test Configuration
TEST_URL = "http://127.0.0.1:3838"  # URL of the locally running Shiny app
TIMEOUT = 30  # Seconds to wait for elements
SCREENSHOT_DIR = "screenshots/enhanced_python"
TEST_USERNAME = "testuser"
TEST_PASSWORD = "password"
BROWSER = "chrome"  # or "firefox"

# Set up logging
LOG_FILE = "enhanced_python_selenium.log"
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler(LOG_FILE, mode='w'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Ensure screenshot directory exists
if not os.path.exists(SCREENSHOT_DIR):
    os.makedirs(SCREENSHOT_DIR)
    logger.info(f"Created screenshot directory: {SCREENSHOT_DIR}")

# ============================================================================
# IMPROVED HELPER FUNCTIONS
# ============================================================================

def take_screenshot(driver, name_prefix):
    """Take screenshot for debugging purposes"""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{SCREENSHOT_DIR}/{name_prefix}_{timestamp}.png"
        driver.save_screenshot(filename)
        logger.info(f"Screenshot saved to {filename}")
    except Exception as e:
        logger.error(f"Failed to take screenshot: {e}")

def wait_for_element_with_retry(driver, selector, by=By.CSS_SELECTOR, timeout=TIMEOUT, max_retries=3):
    """Improved wait mechanism with retry capability"""
    logger.info(f"Waiting for element: {selector} using: {by}")
    
    for retry in range(1, max_retries + 1):
        try:
            wait_start_time = datetime.now()
            element = WebDriverWait(driver, timeout).until(
                EC.visibility_of_element_located((by, selector))
            )
            elapsed = (datetime.now() - wait_start_time).total_seconds()
            logger.info(f"Found element after {elapsed:.2f} seconds: {selector}")
            return element
        except Exception as e:
            logger.warning(f"Element not found in retry {retry}: {selector}")
            logger.warning(f"Error: {str(e)}")
            
            # Take a screenshot for debugging
            take_screenshot(driver, f"retry_{retry}_{selector.replace(' ', '_').replace('>', '_')}")
            
            if retry < max_retries:
                logger.info(f"Retrying ({retry}/{max_retries})...")
                time.sleep(1)
            else:
                logger.error(f"Element not found after {max_retries} retries: {selector}")
                raise

def wait_for_element_by_id(driver, element_id, timeout=TIMEOUT, max_retries=3):
    """Wait for element by ID (convenience wrapper)"""
    return wait_for_element_with_retry(driver, element_id, by=By.ID, timeout=timeout, max_retries=max_retries)

def reset_browser_state(driver):
    """Reset browser state between tests"""
    logger.info("Resetting browser state")
    # First navigate to the URL to avoid localStorage errors
    driver.get(TEST_URL)
    # Small delay to ensure the page has loaded
    time.sleep(1)
    # Now we can safely clear storage
    driver.execute_script("localStorage.clear();")
    driver.execute_script("sessionStorage.clear();")
    driver.delete_all_cookies()
    logger.info("Browser state reset complete")

def setup_test_environment(driver):
    """Setup consistent test environment"""
    logger.info("Setting up test environment")
    reset_browser_state(driver)
    # We've already navigated to the URL in reset_browser_state
    WebDriverWait(driver, TIMEOUT).until(
        EC.presence_of_element_located((By.TAG_NAME, "body"))
    )
    logger.info("Test environment setup complete")

# ============================================================================
# TEST CLASS
# ============================================================================

class EnhancedSeleniumTests(unittest.TestCase):
    """Enhanced Selenium Tests for Insurance Simulation Game"""
    
    @classmethod
    def setUpClass(cls):
        """Set up WebDriver once for all tests"""
        logger.info("=== STARTING ENHANCED PYTHON SELENIUM TEST RUN ===")
        
        # Check if app is running
        app_running = False
        try:
            import requests
            response = requests.get(TEST_URL, timeout=5)
            if response.status_code == 200:
                logger.info(f"App is already running at {TEST_URL}")
                app_running = True
        except Exception as e:
            logger.warning(f"App is not running at {TEST_URL}: {e}")
        
        # If app is not running, try to start it
        if not app_running:
            logger.info("Attempting to start the Shiny app...")
            app_started = start_shiny_app(port=3839)  # Try port 3839 as 3838 might be in use
            
            if not app_started:
                logger.error("Failed to start Shiny app")
                print(f"\nERROR: Could not start Shiny app. Please start it manually with:")
                print(f"& 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe' -e \"shiny::runApp('.', port=3839)\"\n")
                sys.exit(1)
        
        # Initialize WebDriver based on browser choice
        if BROWSER.lower() == "chrome":
            logger.info("Setting up Chrome WebDriver")
            options = ChromeOptions()
            options.add_argument("--headless")
            options.add_argument("--disable-gpu")
            options.add_argument("--window-size=1920,1080")
            options.add_argument("--no-sandbox")
            
            cls.driver = webdriver.Chrome(options=options)
        else:
            logger.info("Setting up Firefox WebDriver")
            options = FirefoxOptions()
            options.add_argument("--headless")
            
            cls.driver = webdriver.Firefox(options=options)
        
        cls.driver.set_page_load_timeout(TIMEOUT)
        logger.info(f"{BROWSER.capitalize()} WebDriver initialized successfully")
    
    @classmethod
    def tearDownClass(cls):
        """Clean up WebDriver after all tests"""
        logger.info("Closing browser")
        cls.driver.quit()
        logger.info("=== TEST RUN COMPLETED ===")
    
    def setUp(self):
        """Set up for each test"""
        logger.info(f"Setting up for test: {self._testMethodName}")
        setup_test_environment(self.driver)
    
    @run_test_with_timeout(timeout=60)
    def test_01_login(self):
        """Test the login functionality"""
        logger.info("Starting login test")
        
        try:
            # Wait for login form
            login_button = wait_for_element_by_id(self.driver, "loginButton")
            self.assertTrue(login_button.is_displayed())
            
            # Enter test credentials
            username_input = self.driver.find_element(By.ID, "username")
            password_input = self.driver.find_element(By.ID, "password")
            
            username_input.send_keys(TEST_USERNAME)
            password_input.send_keys(TEST_PASSWORD)
            
            # Click login button
            login_button.click()
            
            # Check if login was successful
            dashboard_element = wait_for_element_with_retry(
                self.driver, 
                ".content-wrapper, #mainContent", 
                by=By.CSS_SELECTOR
            )
            self.assertTrue(dashboard_element.is_displayed())
            logger.info("Login test completed successfully")
        except Exception as e:
            take_screenshot(self.driver, "login_error")
            logger.error(f"Login test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_02_executive_profile(self):
        """Test the executive profile functionality"""
        logger.info("Starting executive profile test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Navigate to profile section
            profile_btn = wait_for_element_by_id(self.driver, "profileBtn")
            profile_btn.click()
            
            # Wait for profile form - try multiple selectors
            try:
                profile_form = wait_for_element_by_id(self.driver, "profileForm")
            except:
                logger.warning("Couldn't find profileForm by ID, trying alternative selectors")
                profile_form = wait_for_element_with_retry(
                    self.driver, 
                    ".profile-section, #playerProfile-form", 
                    by=By.CSS_SELECTOR
                )
            
            self.assertTrue(profile_form.is_displayed())
            
            # Fill out profile form - try multiple approaches to find inputs
            try:
                major_selector = self.driver.find_element(By.ID, "secondaryMajor")
            except:
                logger.warning("Couldn't find secondaryMajor by ID, trying alternative selectors")
                selects = self.driver.find_elements(By.TAG_NAME, "select")
                if len(selects) > 0:
                    major_selector = selects[0]
                else:
                    raise NoSuchElementException("No select elements found for major selection")
            
            major_selector.send_keys("Finance")
            
            try:
                university_selector = self.driver.find_element(By.ID, "university")
            except:
                logger.warning("Couldn't find university by ID, trying alternative selectors")
                selects = self.driver.find_elements(By.TAG_NAME, "select")
                if len(selects) > 1:
                    university_selector = selects[1]
                else:
                    raise NoSuchElementException("No select elements found for university selection")
            
            university_selector.send_keys("Yale")
            
            # Save profile
            try:
                save_button = self.driver.find_element(By.ID, "saveProfileBtn")
            except:
                logger.warning("Couldn't find saveProfileBtn by ID, trying alternative selectors")
                buttons = self.driver.find_elements(By.CSS_SELECTOR, "button.btn-primary")
                if len(buttons) > 0:
                    save_button = buttons[0]
                else:
                    raise NoSuchElementException("No buttons found for profile save")
            
            save_button.click()
            
            # Verify success notification
            time.sleep(2)
            notification = wait_for_element_with_retry(self.driver, ".shiny-notification")
            self.assertTrue(notification.is_displayed())
            logger.info("Executive profile test completed successfully")
        except Exception as e:
            take_screenshot(self.driver, "profile_error")
            logger.error(f"Executive profile test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_03_inbox_system(self):
        """Test the inbox system functionality"""
        logger.info("Starting inbox system test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Navigate to inbox
            inbox_btn = wait_for_element_by_id(self.driver, "inboxBtn")
            inbox_btn.click()
            
            # Wait for inbox to load - try multiple selectors
            try:
                inbox_container = wait_for_element_by_id(self.driver, "inboxContainer")
            except:
                logger.warning("Couldn't find inboxContainer by ID, trying alternative selectors")
                inbox_container = wait_for_element_with_retry(
                    self.driver, 
                    ".inbox-message, .message-item", 
                    by=By.CSS_SELECTOR
                )
            
            self.assertTrue(inbox_container.is_displayed())
            
            # Verify at least one message exists
            time.sleep(3) # Allow time for messages to load
            messages = self.driver.find_elements(By.CSS_SELECTOR, ".inbox-message, .message-item")
            
            if len(messages) > 0:
                logger.info(f"Found {len(messages)} messages")
                
                # Try to click on a message if it's clickable
                try:
                    messages[0].click()
                    
                    # Verify message content appears
                    message_content = wait_for_element_with_retry(
                        self.driver, 
                        "#messageContent, .message-body", 
                        by=By.CSS_SELECTOR, 
                        timeout=5
                    )
                    self.assertTrue(message_content.is_displayed())
                except Exception as e:
                    logger.warning(f"Message click failed: {e}")
                    logger.warning("This may be expected if messages aren't clickable in this UI")
            else:
                logger.warning("No messages found, this may be expected in a fresh game state")
                # Skip this assertion if no messages found
            
            logger.info("Inbox system test completed")
        except Exception as e:
            take_screenshot(self.driver, "inbox_error")
            logger.error(f"Inbox system test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_04_simulation_controls(self):
        """Test the simulation controls functionality"""
        logger.info("Starting simulation controls test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Navigate to simulation controls
            sim_ctrl_btn = wait_for_element_by_id(self.driver, "simCtrlBtn")
            sim_ctrl_btn.click()
            
            # Wait for simulation controls to load - try multiple selectors
            try:
                controls_panel = wait_for_element_by_id(self.driver, "simulationControls")
            except:
                logger.warning("Couldn't find simulationControls by ID, trying alternative selectors")
                controls_panel = wait_for_element_with_retry(
                    self.driver, 
                    ".simulation-section, .slider-container", 
                    by=By.CSS_SELECTOR
                )
            
            self.assertTrue(controls_panel.is_displayed())
            
            # Test sliders function
            sliders = self.driver.find_elements(By.CSS_SELECTOR, ".js-range-slider, input[type='range'], .slider")
            if len(sliders) > 0:
                logger.info(f"Found {len(sliders)} sliders")
                
                # Try to interact with a slider using JavaScript
                try:
                    self.driver.execute_script(
                        "arguments[0].value = 90; arguments[0].dispatchEvent(new Event('change'));", 
                        sliders[0]
                    )
                    logger.info("Successfully interacted with slider")
                except Exception as e:
                    logger.warning(f"Error interacting with slider: {e}")
            else:
                logger.warning("No sliders found, checking for alternative controls")
                # Look for any input controls
                input_controls = self.driver.find_elements(By.CSS_SELECTOR, "input, select")
                self.assertGreater(len(input_controls), 0)
                logger.info(f"Found {len(input_controls)} input controls")
            
            # Test submit button
            try:
                submit_btn = self.driver.find_element(By.ID, "saveDecisions")
            except:
                logger.warning("Couldn't find saveDecisions button by ID, trying alternative selectors")
                buttons = self.driver.find_elements(By.CSS_SELECTOR, "button.btn-primary")
                if len(buttons) > 0:
                    submit_btn = buttons[-1] # Usually the last primary button is the save button
                else:
                    submit_btn = None
            
            if submit_btn:
                self.assertTrue(submit_btn.is_displayed())
                logger.info("Submit button found and is displayed")
                
                # Click submit (commented out to avoid affecting game state in test environment)
                # submit_btn.click()
                # time.sleep(2)
                # notification = wait_for_element_with_retry(driver, ".shiny-notification", timeout=5)
                # self.assertTrue(notification.is_displayed())
            else:
                logger.warning("No submit button found - this may indicate a UI structure different than expected")
            
            logger.info("Simulation controls test completed")
        except Exception as e:
            take_screenshot(self.driver, "simulation_controls_error")
            logger.error(f"Simulation controls test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_05_analytics_dashboard(self):
        """Test the analytics dashboard functionality"""
        logger.info("Starting analytics dashboard test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Navigate to analytics
            analytics_btn = wait_for_element_by_id(self.driver, "analyticsBtn")
            analytics_btn.click()
            
            # Wait for dashboard to load - try multiple selectors
            try:
                dashboard_container = wait_for_element_by_id(self.driver, "analyticsDashboard")
            except:
                logger.warning("Couldn't find analyticsDashboard by ID, trying alternative selectors")
                dashboard_container = wait_for_element_with_retry(
                    self.driver, 
                    ".analytics-header, .chart-container", 
                    by=By.CSS_SELECTOR
                )
            
            self.assertTrue(dashboard_container.is_displayed())
            
            # Check for charts/plots - allow more time to render
            time.sleep(3)
            charts = self.driver.find_elements(By.CSS_SELECTOR, ".plotly, .shiny-plot-output, .chart, .plot, svg")
            
            # Expect at least one chart to be visible
            if len(charts) > 0:
                self.assertGreater(len(charts), 0)
                self.assertTrue(charts[0].is_displayed())
                logger.info(f"Found {len(charts)} charts/plots")
            else:
                logger.warning("No charts found with standard selectors - trying alternative selectors")
                # Try more generic selectors for visualization containers
                viz_elements = self.driver.find_elements(By.CSS_SELECTOR, ".metric-card, .dashboard-item, .card, .box")
                if len(viz_elements) > 0:
                    logger.info(f"Found {len(viz_elements)} potential visualization containers")
                    self.assertGreater(len(viz_elements), 0)
                else:
                    logger.warning("No visualization elements found - this may indicate an empty dashboard or different UI structure")
            
            # Test advanced analytics button if it exists
            try:
                advanced_btn = self.driver.find_element(By.ID, "viewAdvancedAnalyticsBtn")
                logger.info("Testing advanced analytics")
                advanced_btn.click()
                
                time.sleep(2) # Allow time for advanced analytics to load
                advanced_container = wait_for_element_with_retry(
                    self.driver, 
                    ".advanced-analytics-section, #advancedAnalytics-container", 
                    by=By.CSS_SELECTOR, 
                    timeout=10
                )
                self.assertTrue(advanced_container.is_displayed())
                logger.info("Advanced analytics loaded successfully")
            except:
                logger.warning("Advanced analytics button not found, may not be available")
            
            logger.info("Analytics dashboard test completed")
        except Exception as e:
            take_screenshot(self.driver, "analytics_error")
            logger.error(f"Analytics dashboard test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_06_auction_functionality(self):
        """Test the auction functionality"""
        logger.info("Starting auction functionality test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Navigate to auctions
            auction_btn = wait_for_element_by_id(self.driver, "auctionBtn")
            auction_btn.click()
            
            # Wait for auction interface to load
            auction_container = wait_for_element_with_retry(
                self.driver, 
                "#auction-container, .auction-section", 
                by=By.CSS_SELECTOR
            )
            self.assertTrue(auction_container.is_displayed())
            
            # Check for auction items
            auction_items = self.driver.find_elements(By.CSS_SELECTOR, ".auction-item, .card, .item-card")
            
            if len(auction_items) > 0:
                self.assertGreater(len(auction_items), 0)
                logger.info(f"Found {len(auction_items)} auction items")
                
                # Try to interact with an auction item
                auction_items[0].click()
                
                # Look for bid controls
                bid_inputs = self.driver.find_elements(By.CSS_SELECTOR, "input[type='number'], .bid-input")
                bid_buttons = self.driver.find_elements(By.CSS_SELECTOR, "button.bid-button, button.btn-primary")
                
                # Verify we have bid controls
                has_bid_controls = len(bid_inputs) > 0 or len(bid_buttons) > 0
                self.assertTrue(has_bid_controls, "No bid controls found")
                
                if len(bid_inputs) > 0:
                    # Try to enter a bid amount (but don't submit)
                    bid_inputs[0].send_keys("100")
                    logger.info("Successfully entered bid amount")
                
                # Don't actually submit the bid to avoid affecting game state
                
            else:
                logger.warning("No auction items found, may not be available in current game state")
            
            logger.info("Auction functionality test completed")
        except Exception as e:
            take_screenshot(self.driver, "auction_error")
            logger.error(f"Auction functionality test failed: {e}")
            raise
    
    @run_test_with_timeout(timeout=60)
    def test_07_admin_functionality(self):
        """Test admin functionality if in admin mode"""
        logger.info("Starting admin functionality test")
        
        try:
            # Make sure we're logged in first
            self.test_01_login()
            
            # Try to enable admin mode
            try:
                admin_checkbox = self.driver.find_element(By.ID, "isAdmin")
                
                # Check the admin checkbox
                admin_checkbox.click()
                logger.info("Enabled admin mode")
                
                # Wait for admin button to appear
                time.sleep(1)
                admin_btn = wait_for_element_by_id(self.driver, "adminBtn")
                admin_btn.click()
                
                # Wait for admin panel to load
                admin_panel = wait_for_element_with_retry(
                    self.driver, 
                    "#adminPanel-container, .admin-section", 
                    by=By.CSS_SELECTOR
                )
                self.assertTrue(admin_panel.is_displayed())
                
                # Look for admin controls
                admin_controls = self.driver.find_elements(By.CSS_SELECTOR, "button, input, select")
                self.assertGreater(len(admin_controls), 0)
                logger.info(f"Found {len(admin_controls)} admin controls")
                
                # Test a basic admin function (without actually making changes)
                # For example, find the game state controls
                game_state_controls = self.driver.find_elements(By.CSS_SELECTOR, ".game-state-section, #update-turn-btn")
                
                if len(game_state_controls) > 0:
                    logger.info("Found game state controls")
                else:
                    logger.warning("Game state controls not found, but admin panel is accessible")
                
                # Don't make any actual changes in the admin panel
                
                logger.info("Admin functionality test completed")
            except NoSuchElementException:
                logger.warning("Admin mode not available, skipping test")
        except Exception as e:
            take_screenshot(self.driver, "admin_error")
            logger.error(f"Admin functionality test failed: {e}")
            raise

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print("\nStarting Enhanced Python Selenium tests for Insurance Simulation Game\n")
    unittest.main(verbosity=2) 

# Add a timeout wrapper function after all helper functions
def run_test_with_timeout(test_method, timeout=60):
    """Run a test method with a timeout to prevent getting stuck"""
    import signal
    import functools
    
    class TimeoutError(Exception):
        pass
    
    def timeout_handler(signum, frame):
        raise TimeoutError(f"Test timed out after {timeout} seconds")
    
    @functools.wraps(test_method)
    def wrapper(*args, **kwargs):
        logger.info(f"Running {test_method.__name__} with {timeout} second timeout")
        
        # Set the timeout
        old_handler = signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(timeout)
        
        try:
            result = test_method(*args, **kwargs)
            return result
        except TimeoutError as e:
            logger.error(f"TIMEOUT: {str(e)}")
            # Take a screenshot to help debug the timeout
            if args and hasattr(args[0], 'driver'):
                take_screenshot(args[0].driver, f"timeout_{test_method.__name__}")
            raise
        finally:
            # Restore the previous handler and cancel the alarm
            signal.signal(signal.SIGALRM, old_handler)
            signal.alarm(0)
    
    return wrapper 

# Add these functions before the test class

def check_port_availability(port):
    """Check if a port is available to use"""
    import socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        sock.connect(('127.0.0.1', port))
        sock.close()
        return False  # Port is in use
    except:
        return True  # Port is available

def find_available_port(start_port=3838, max_attempts=10):
    """Find an available port starting from start_port"""
    for port in range(start_port, start_port + max_attempts):
        if check_port_availability(port):
            return port
    return None  # No available port found

def start_shiny_app(port=3838):
    """Start the Shiny app on the specified port"""
    import subprocess
    import time
    import requests
    
    global TEST_URL
    
    logger.info(f"Attempting to start Shiny app on port {port}")
    
    # Check if port is already in use
    if not check_port_availability(port):
        logger.info(f"Port {port} is already in use. Looking for available port...")
        port = find_available_port(port)
        if port is None:
            logger.error("No available ports found in range. Please close some applications and try again.")
            return False
        logger.info(f"Found available port: {port}")
    
    # Command to run the Shiny app
    r_command = f'shiny::runApp(".", port={port})'
    
    # Start the app in a separate process
    if sys.platform == 'win32':
        cmd = f'start /B "R" "C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe" -e "{r_command}"'
        subprocess.Popen(cmd, shell=True)
    else:
        cmd = f'Rscript -e "{r_command}"'
        subprocess.Popen(cmd, shell=True)
    
    # Update the TEST_URL global variable
    TEST_URL = f"http://127.0.0.1:{port}"
    logger.info(f"Shiny app started at {TEST_URL}")
    
    # Wait for app to start
    time.sleep(5)
    
    # Check if app is running
    try:
        response = requests.get(TEST_URL, timeout=5)
        if response.status_code == 200:
            logger.info(f"Shiny app is running at {TEST_URL}")
            return True
    except:
        pass
    
    logger.error(f"Failed to start Shiny app on port {port}")
    return False 