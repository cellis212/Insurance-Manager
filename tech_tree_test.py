import time
import os
import logging
import subprocess
import socket
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='tech_tree_test.log',
    filemode='w'
)
logger = logging.getLogger()

# Add console handler
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logger.addHandler(console)

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

def setup_driver():
    """Set up and return a Chrome WebDriver."""
    chrome_options = Options()
    # Run in normal mode for debugging
    # chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
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
        logger.error(f"Element not found: {selector}")
        return None

def start_shiny_app():
    """Start the Shiny app using a direct command."""
    try:
        # Find an available port
        port = find_available_port()
        logger.info(f"Using port {port} for Shiny app")
        
        # Set path to Rscript.exe
        r_script_path = r'C:\Program Files\R\R-4.4.1\bin\Rscript.exe'
        
        # Create a simpler command
        cmd = [r_script_path, "-e", f"shiny::runApp(port={port}, launch.browser=FALSE)"]
        
        # Launch the R script directly
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE,
            creationflags=subprocess.CREATE_NO_WINDOW
        )
        
        logger.info(f"Started Shiny app process with PID: {process.pid}")
        
        # Wait for app to start by checking if the port is open
        retries = 0
        max_retries = 30
        while retries < max_retries:
            time.sleep(1)
            if is_port_in_use(port):
                logger.info(f"App is listening on port {port} after {retries+1} seconds")
                time.sleep(3)  # Give app a bit more time to initialize fully
                break
            retries += 1
        
        if retries >= max_retries:
            logger.error("App didn't start listening on port in time")
            return None, None
            
        return process, port
    except Exception as e:
        logger.error(f"Failed to start Shiny app: {str(e)}")
        return None, None

def stop_shiny_app():
    """Stop all running Rscript processes."""
    try:
        subprocess.run(
            ["taskkill", "/F", "/IM", "Rscript.exe", "/T"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        logger.info("Stopped all R processes")
    except Exception as e:
        logger.error(f"Failed to stop R processes: {str(e)}")

def print_page_source(driver, file_name="page_source.html"):
    """Save page source to a file for debugging."""
    with open(file_name, 'w', encoding='utf-8') as f:
        f.write(driver.page_source)
    logger.info(f"Saved page source to {file_name}")

def verify_app_implementation():
    """Simple test to verify the app loads and the tech tree can be accessed."""
    driver = None
    process = None
    
    try:
        # Stop any running R processes
        stop_shiny_app()
        
        # Start the app
        process, port = start_shiny_app()
        if not process or not port:
            logger.error("Failed to start Shiny app")
            return False
        
        # Setup the driver
        driver = setup_driver()
        app_url = f"http://127.0.0.1:{port}"
        driver.get(app_url)
        logger.info(f"Navigating to app at {app_url}")
        
        # Wait for app to load and take screenshot
        time.sleep(5)
        os.makedirs("verification", exist_ok=True)
        driver.save_screenshot("verification/app_loaded.png")
        print_page_source(driver, "verification/initial_page.html")
        
        # Try to find and click on the tech tree button
        buttons = driver.find_elements(By.TAG_NAME, "button")
        tech_button = None
        
        # Log all buttons found
        logger.info(f"Found {len(buttons)} buttons on the page:")
        for i, button in enumerate(buttons):
            try:
                text = button.text.strip()
                logger.info(f"Button {i}: '{text}'")
                if "Tech Tree" in text or "Skills" in text:
                    tech_button = button
                    logger.info(f"Found Tech Tree button with text: '{text}'")
            except:
                logger.info(f"Button {i}: <error getting text>")
        
        if tech_button:
            # Click the button and capture the result
            tech_button.click()
            logger.info("Clicked on Tech Tree button")
            time.sleep(3)
            driver.save_screenshot("verification/tech_tree_clicked.png")
            print_page_source(driver, "verification/tech_tree_page.html")
            
            # Check for the tech tree title
            h2_elements = driver.find_elements(By.TAG_NAME, "h2")
            for h2 in h2_elements:
                text = h2.text.strip()
                logger.info(f"Found h2: '{text}'")
                if "Tech Tree" in text or "Skill" in text:
                    logger.info("Tech Tree page loaded successfully")
                    driver.save_screenshot("verification/tech_tree_confirmed.png")
                    return True
            
            logger.error("Could not confirm Tech Tree page loaded")
            return False
        else:
            logger.error("Tech Tree button not found")
            return False
    
    except Exception as e:
        logger.error(f"Error during test: {str(e)}")
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
    logging.info("Starting tech tree verification test...")
    
    # Create screenshots directory
    os.makedirs("screenshots", exist_ok=True)
    
    result = verify_app_implementation()
    logging.info(f"Test result: {'PASS' if result else 'FAIL'}")
    
    exit(0 if result else 1) 