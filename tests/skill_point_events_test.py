import os
import time
import subprocess
import socket
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

# Configure logging
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='skill_point_events_test.log'
)
logger = logging.getLogger(__name__)

def is_port_in_use(port):
    """Check if a port is already in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def find_available_port(start=8000, end=9000):
    """Find an available port in the given range."""
    for port in range(start, end):
        if not is_port_in_use(port):
            return port
    raise RuntimeError("No available ports found")

def start_shiny_app():
    """Start the Shiny app on an available port."""
    port = find_available_port()
    logger.info(f"Starting Shiny app on port {port}")
    
    r_script_path = r'C:\Program Files\R\R-4.4.1\bin\Rscript.exe'
    cmd = [r_script_path, "-e", f"shiny::runApp(port={port}, launch.browser=FALSE)"]
    
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE,
        creationflags=subprocess.CREATE_NO_WINDOW
    )
    
    # Wait for app to start by checking port
    retries = 0
    while retries < 30:
        time.sleep(1)
        if is_port_in_use(port):
            time.sleep(3)  # Additional time for app to fully initialize
            break
        retries += 1
        logger.info(f"Waiting for app to start (attempt {retries}/30)")
    
    if retries >= 30:
        logger.error("Timeout waiting for app to start")
        return None, None
    
    return process, port

def stop_shiny_app():
    """Stop all running R processes."""
    logger.info("Stopping all R processes")
    subprocess.run(
        ["taskkill", "/F", "/IM", "Rscript.exe", "/T"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

def setup_driver():
    """Set up and return a Chrome WebDriver."""
    logger.info("Setting up Chrome WebDriver")
    chrome_options = Options()
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    # Uncomment for headless testing
    # chrome_options.add_argument("--headless=new")
    
    service = Service()
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver

def wait_for_element(driver, selector, by=By.CSS_SELECTOR, timeout=20):
    """Wait for an element to be present and visible."""
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.visibility_of_element_located((by, selector))
        )
        return element
    except TimeoutException:
        logger.error(f"Timeout waiting for element: {selector}")
        return None

def test_skill_point_events():
    """Test skill point award events functionality."""
    # Ensure verification directory exists
    os.makedirs("verification", exist_ok=True)
    
    driver = None
    process = None
    
    try:
        # First ensure no previous R processes are running
        stop_shiny_app()
        
        # Start the app
        process, port = start_shiny_app()
        if not process or not port:
            logger.error("Failed to start Shiny app")
            return False
            
        # Setup driver and navigate to app
        driver = setup_driver()
        app_url = f"http://127.0.0.1:{port}"
        driver.get(app_url)
        logger.info(f"Navigated to {app_url}")
        
        # Take screenshot of initial app state
        driver.save_screenshot("verification/app_loaded.png")
        
        # Set up a profile to enable skill points testing
        wait_for_element(driver, "#username")
        driver.find_element(By.ID, "username").send_keys("TestUser")
        driver.find_element(By.ID, "saveProfileBtn").click()
        logger.info("Created test profile")
        
        # Enable admin mode for testing
        wait_for_element(driver, "#isAdmin")
        driver.find_element(By.ID, "isAdmin").click()
        logger.info("Admin mode enabled")
        
        # Navigate to tech tree
        wait_for_element(driver, "#techTreeBtn")
        driver.find_element(By.ID, "techTreeBtn").click()
        logger.info("Navigated to Tech Tree")
        
        # Take screenshot of tech tree
        driver.save_screenshot("verification/tech_tree_page.png")
        
        # Check initial skill points
        skill_points_element = wait_for_element(driver, ".skill-points-display")
        initial_points = int(skill_points_element.text.strip())
        logger.info(f"Initial skill points: {initial_points}")
        
        # Test point history button
        wait_for_element(driver, "#viewPointHistoryBtn")
        driver.find_element(By.ID, "viewPointHistoryBtn").click()
        
        # Verify history modal shows up
        history_modal = wait_for_element(driver, ".modal-title")
        assert history_modal.text == "Skill Point History", "History modal not showing"
        logger.info("Point history modal displayed correctly")
        driver.save_screenshot("verification/point_history_initial.png")
        
        # Close modal
        wait_for_element(driver, ".modal-footer .btn")
        driver.find_element(By.CSS_SELECTOR, ".modal-footer .btn").click()
        
        # Wait for test buttons to appear
        test_button = wait_for_element(driver, "#testPerformanceEvent", timeout=5)
        assert test_button is not None, "Test buttons not visible"
        logger.info("Test buttons visible")
        
        # Click test performance event button
        driver.find_element(By.ID, "testPerformanceEvent").click()
        logger.info("Triggered performance event")
        time.sleep(2)  # Wait for notification
        
        # Check that points increased
        skill_points_element = wait_for_element(driver, ".skill-points-display")
        updated_points = int(skill_points_element.text.strip())
        assert updated_points == initial_points + 1, f"Expected {initial_points + 1} points, got {updated_points}"
        logger.info(f"Points increased to {updated_points}")
        
        # Check point history again
        driver.find_element(By.ID, "viewPointHistoryBtn").click()
        time.sleep(1)
        
        # Verify event is in history
        history_table = wait_for_element(driver, ".modal-body .table")
        assert "Achieved quarterly profit target" in history_table.text, "Event not found in history"
        logger.info("Performance event record found in history")
        driver.save_screenshot("verification/point_history_after_event.png")
        
        # Close modal
        wait_for_element(driver, ".modal-footer .btn")
        driver.find_element(By.CSS_SELECTOR, ".modal-footer .btn").click()
        
        # Go to inbox to check message
        wait_for_element(driver, "#inboxBtn")
        driver.find_element(By.ID, "inboxBtn").click()
        logger.info("Navigated to inbox")
        
        # Verify inbox message
        inbox_messages = wait_for_element(driver, ".inbox-message")
        assert "Quarterly Performance Achievement" in inbox_messages.text, "Inbox message not found"
        logger.info("Inbox message found")
        driver.save_screenshot("verification/inbox_with_event_message.png")
        
        logger.info("Skill point events test completed successfully!")
        return True
    except Exception as e:
        logger.error(f"Test failed: {str(e)}")
        if driver:
            driver.save_screenshot("verification/error.png")
        return False
    finally:
        if driver:
            driver.quit()
        if process and process.poll() is None:
            process.terminate()
        stop_shiny_app()

if __name__ == "__main__":
    success = test_skill_point_events()
    print("Test result:", "SUCCESS" if success else "FAILURE") 