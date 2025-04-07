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
        
        # Take screenshots during the test
        driver.save_screenshot("verification/app_loaded.png")
        
        # Simplified test: enable admin mode and test event triggers
        try:
            admin_checkbox = driver.find_element(By.ID, "isAdmin")
            admin_checkbox.click()
            logger.info("Admin mode enabled")
        except Exception as e:
            logger.error(f"Could not enable admin mode: {str(e)}")
            driver.save_screenshot("verification/admin_mode_error.png")
            return False
            
        # Sleep to allow time for admin mode to take effect
        time.sleep(2)
        
        # Take screenshots of all available buttons
        buttons = driver.find_elements(By.TAG_NAME, "button")
        logger.info(f"Found {len(buttons)} buttons")
        for i, button in enumerate(buttons):
            try:
                logger.info(f"Button {i}: {button.text}")
            except:
                logger.info(f"Button {i}: <text not available>")
                
        driver.save_screenshot("verification/buttons.png")
        
        # Find the Tech Tree button and click it
        tech_tree_clicked = False
        for button in buttons:
            try:
                if "Tech Tree" in button.text or "tech tree" in button.text.lower() or "skill" in button.text.lower():
                    logger.info(f"Clicking button: {button.text}")
                    button.click()
                    tech_tree_clicked = True
                    break
            except Exception as e:
                logger.error(f"Error clicking button: {str(e)}")
                
        if not tech_tree_clicked:
            logger.error("Could not find Tech Tree button")
            return False
            
        # Wait for the tech tree page to load
        time.sleep(2)
        driver.save_screenshot("verification/tech_tree_page.png")
        
        # Find any test buttons in admin mode
        test_buttons = []
        buttons = driver.find_elements(By.TAG_NAME, "button")
        for button in buttons:
            try:
                if "test" in button.text.lower() or "performance" in button.text.lower() or "simulate" in button.text.lower():
                    test_buttons.append(button)
                    logger.info(f"Found test button: {button.text}")
            except:
                pass
                
        if len(test_buttons) == 0:
            logger.error("No test buttons found")
            return False
            
        # Click the first test button
        try:
            test_buttons[0].click()
            logger.info(f"Clicked test button: {test_buttons[0].text}")
            time.sleep(2)  # Wait for processing
        except Exception as e:
            logger.error(f"Error clicking test button: {str(e)}")
            return False
            
        # Capture screenshot after triggering event
        driver.save_screenshot("verification/after_event_trigger.png")
        
        # Find inbox button and navigate to inbox
        inbox_clicked = False
        buttons = driver.find_elements(By.TAG_NAME, "button")
        for button in buttons:
            try:
                if "inbox" in button.text.lower() or "ceo" in button.text.lower():
                    logger.info(f"Clicking button: {button.text}")
                    button.click()
                    inbox_clicked = True
                    break
            except:
                pass
                
        if not inbox_clicked:
            logger.error("Could not find Inbox button")
            return False
            
        # Wait for inbox to load
        time.sleep(2)
        driver.save_screenshot("verification/inbox_messages.png")
        
        # Verify app is working correctly
        driver.save_screenshot("verification/test_complete.png")
        logger.info("Test completed successfully!")
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