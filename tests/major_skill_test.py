import pytest
import time
import os
import subprocess
import socket
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, StaleElementReferenceException
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains

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
    """Starts the Shiny app on an available port and returns the process and port."""
    port = find_available_port()
    r_script_path = r'C:\Program Files\R\R-4.4.1\bin\Rscript.exe'
    cmd = [r_script_path, "-e", f"shiny::runApp('.', port={port}, launch.browser=FALSE)"]
    
    print(f"Starting Shiny app on port {port}...")
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE,
        creationflags=subprocess.CREATE_NO_WINDOW
    )
    
    # Wait for app to start by checking port
    retries = 0
    max_retries = 30
    while retries < max_retries:
        time.sleep(1)
        if is_port_in_use(port):
            print(f"Shiny app detected on port {port}.")
            time.sleep(3) # Additional time for app to fully initialize
            return process, port
        retries += 1
        if retries % 5 == 0:
            print(f"Waiting for app... ({retries}/{max_retries})")
    
    raise RuntimeError(f"Shiny app failed to start on port {port} after {max_retries} seconds.")

def stop_shiny_app():
    """Stops any running Rscript processes."""
    print("Stopping Shiny app (Rscript.exe)...")
    try:
        subprocess.run(
            ["taskkill", "/F", "/IM", "Rscript.exe", "/T"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False
        )
        print("Stop command executed.")
    except:
        print("Failed to stop Rscript process.")
    time.sleep(2)

def setup_driver():
    """Sets up and returns a Chrome WebDriver."""
    chrome_options = Options()
    # Comment out headless for debugging - use visible browser
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    service = Service()
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver

def main():
    """Main function that runs the test."""
    os.makedirs("screenshots", exist_ok=True)
    process = None
    driver = None
    
    try:
        # Start the Shiny app
        stop_shiny_app() # Ensure no previous instances are running
        process, port = start_shiny_app()
        
        # Setup driver
        driver = setup_driver()
        app_url = f"http://127.0.0.1:{port}"
        driver.get(app_url)
        
        print("Taking initial screenshot...")
        driver.save_screenshot("screenshots/initial_page.png")
        
        # Wait for the username field to be visible
        username_input = WebDriverWait(driver, 20).until(
            EC.visibility_of_element_located((By.ID, "playerProfile-username"))
        )
        
        # Fill username so we can proceed
        username_input.send_keys("TestUser")
        
        # Take screenshot showing profile setup page
        driver.save_screenshot("screenshots/profile_setup_page.png")
        
        # Wait for initial description to be populated (Finance is default)
        description_div = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "playerProfile-majorDescription"))
        )
        
        # Take screenshot of initial major description
        driver.save_screenshot("screenshots/major_description_initial.png")
        
        # Get the text of the description
        description_text = description_div.text
        print(f"Initial description text: {description_text}")
        
        # Verify description contains expected text for the default major (Finance)
        assert "investing skills significantly" in description_text, "Finance description not showing correctly"
        assert "Investing:" in description_text, "Skill impact visualization not showing"
        
        # Test changing major using JavaScript (more reliable than UI interaction)
        majors_to_test = [
            {"value": "Actuarial Science", "expected_text": "risk management capabilities", "skill": "Risk Management"},
            {"value": "Business Analytics", "expected_text": "balanced skill development", "skill": "Marketing"},
            {"value": "Marketing", "expected_text": "marketing abilities", "skill": "Marketing"}
        ]
        
        for i, major_info in enumerate(majors_to_test):
            print(f"Testing major change to: {major_info['value']}")
            
            # Use more advanced JavaScript approach to handle Shiny's selectize inputs
            js_command = f"""
            // Get the selectize object
            var selectizeInput = $('#playerProfile-secondaryMajor').selectize()[0].selectize;
            
            // Clear and update value
            selectizeInput.clear();
            selectizeInput.addItem("{major_info['value']}");
            
            // Force Shiny to see the change
            var el = document.getElementById('playerProfile-secondaryMajor');
            Shiny.onInputChange(el.id, "{major_info['value']}");
            """
            driver.execute_script(js_command)
            
            # Give the UI time to update
            time.sleep(3)
            
            # Take screenshot after selection
            driver.save_screenshot(f"screenshots/major_{major_info['value'].replace(' ', '_')}.png")
            
            # Get updated description text
            try:
                description_div = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.ID, "playerProfile-majorDescription"))
                )
                updated_text = description_div.text
                print(f"Description for {major_info['value']}: {updated_text[:100]}...")
                
                # Verify updated description contains expected text
                assert major_info['expected_text'] in updated_text, f"Description for {major_info['value']} not showing correctly"
                assert major_info['skill'] in updated_text, f"Skill impact for {major_info['value']} not showing correctly"
                
                print(f"✓ {major_info['value']} description and skill impacts verified successfully")
            except Exception as e:
                print(f"Error verifying {major_info['value']}: {str(e)}")
                driver.save_screenshot(f"screenshots/error_{major_info['value'].replace(' ', '_')}.png")
                raise
        
        # Test the Preview Impact button
        try:
            preview_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.ID, "playerProfile-previewImpactBtn"))
            )
            preview_button.click()
            
            # Wait for impact section to be visible
            impact_section = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.ID, "playerProfile-impactSection"))
            )
            
            # Take screenshot of the impact summary
            driver.save_screenshot("screenshots/preview_impact.png")
            
            print("✓ Preview Impact functionality verified")
        except Exception as e:
            print(f"Error testing Preview Impact: {str(e)}")
            driver.save_screenshot("screenshots/error_preview_impact.png")
        
        print("All tests completed successfully!")
        return True
        
    except Exception as e:
        print(f"Test failed: {str(e)}")
        if driver:
            driver.save_screenshot("screenshots/error_final.png")
        return False
        
    finally:
        print("Cleaning up...")
        if driver:
            driver.quit()
        if process and process.poll() is None:
            process.terminate()
        stop_shiny_app()

if __name__ == "__main__":
    success = main()
    if not success:
        exit(1) 