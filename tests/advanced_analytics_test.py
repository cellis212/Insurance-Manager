import time
import os
import logging
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options

# Setup logging
logging.basicConfig(
    filename='advanced_analytics_test.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Configuration
APP_URL = "http://localhost:3839"
SCREENSHOTS_DIR = "screenshots/advanced_analytics"
TIMEOUT = 10

# Ensure screenshots directory exists
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

def take_screenshot(driver, name):
    """Take a screenshot and save it to the screenshots directory"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{SCREENSHOTS_DIR}/{name}_{timestamp}.png"
    driver.save_screenshot(filename)
    logging.info(f"Screenshot saved: {filename}")
    return filename

def test_advanced_analytics():
    """Test the advanced analytics module functionality"""
    
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920,1080")
    
    try:
        # Setup WebDriver with automatic ChromeDriver management
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        logging.info("Starting Advanced Analytics module test")
        
        # Navigate to the application
        driver.get(APP_URL)
        take_screenshot(driver, "initial_page")
        logging.info(f"Navigated to {APP_URL}")
        
        # Login with admin mode
        wait = WebDriverWait(driver, TIMEOUT)
        
        # Check the admin checkbox
        admin_checkbox = wait.until(EC.element_to_be_clickable((By.ID, "isAdmin")))
        admin_checkbox.click()
        logging.info("Enabled admin mode")
        
        # Click on Analytics button
        analytics_btn = wait.until(EC.element_to_be_clickable((By.ID, "analyticsBtn")))
        analytics_btn.click()
        logging.info("Clicked on Analytics button")
        
        # Wait for advanced analytics module to load
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, ".nav-tabs")))
        take_screenshot(driver, "advanced_analytics_loaded")
        logging.info("Advanced analytics module loaded")
        
        # Test each tab in the advanced analytics module
        
        # 1. Test Predictive Models tab (default tab)
        generate_forecast_btn = wait.until(EC.element_to_be_clickable((By.ID, "advancedAnalytics-generateForecastBtn")))
        generate_forecast_btn.click()
        logging.info("Clicked Generate Forecast button")
        
        # Wait for forecast plot to load
        time.sleep(2)  # Allow time for the forecast to be generated
        take_screenshot(driver, "forecast_tab")
        logging.info("Forecast tab tested")
        
        # 2. Test Scenario Analysis tab
        scenario_tab = wait.until(EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'Scenario Analysis')]")))
        scenario_tab.click()
        logging.info("Clicked Scenario Analysis tab")
        
        run_scenario_btn = wait.until(EC.element_to_be_clickable((By.ID, "advancedAnalytics-runScenarioBtn")))
        run_scenario_btn.click()
        logging.info("Clicked Run Scenario button")
        
        # Wait for scenario plot to load
        time.sleep(2)
        take_screenshot(driver, "scenario_tab")
        logging.info("Scenario Analysis tab tested")
        
        # 3. Test Competitive Analysis tab
        competitive_tab = wait.until(EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'Competitive Analysis')]")))
        competitive_tab.click()
        logging.info("Clicked Competitive Analysis tab")
        
        # Wait for competitive analysis charts to load
        time.sleep(2)
        take_screenshot(driver, "competitive_tab")
        logging.info("Competitive Analysis tab tested")
        
        # 4. Test Trend Analysis tab
        trend_tab = wait.until(EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'Trend Analysis')]")))
        trend_tab.click()
        logging.info("Clicked Trend Analysis tab")
        
        # Wait for trend analysis chart to load
        time.sleep(2)
        take_screenshot(driver, "trend_tab")
        logging.info("Trend Analysis tab tested")
        
        logging.info("Advanced Analytics test completed successfully")
        
    except Exception as e:
        logging.error(f"Test failed: {str(e)}")
        if 'driver' in locals():
            take_screenshot(driver, "error")
        raise
    finally:
        if 'driver' in locals():
            driver.quit()
            logging.info("Browser closed")

if __name__ == "__main__":
    test_advanced_analytics() 