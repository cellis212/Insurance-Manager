#!/usr/bin/env python3
# Run Office Navigation Test with App server
# This script starts the Shiny app and then runs the office navigation test

import os
import sys
import subprocess
import time
import atexit
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

# Global variable to store the app process
app_process = None

def install_r_packages():
    """Install required R packages"""
    logger.info("Installing required R packages...")
    
    # Get path to R executable
    r_exe = 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe'
    
    # Get the path to the install_test_packages.R script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    install_script = os.path.join(script_dir, "install_test_packages.R")
    
    # Run the installation script
    try:
        result = subprocess.run([r_exe, install_script], 
                              capture_output=True, text=True, check=True)
        
        # Log output
        if result.stdout:
            logger.info(f"Package installation output:\n{result.stdout}")
        if result.stderr:
            logger.error(f"Package installation errors:\n{result.stderr}")
            
        logger.info("R packages installed successfully")
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to install R packages: {e}")
        if e.stdout:
            logger.info(f"Output: {e.stdout}")
        if e.stderr:
            logger.error(f"Error: {e.stderr}")
        sys.exit(1)

def start_app():
    """Start the Shiny application"""
    global app_process
    
    logger.info("Starting Shiny application...")
    
    # Get path to R executable
    r_exe = 'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe'
    
    # Get the path to the start_app.R script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    start_script = os.path.join(script_dir, "start_app.R")
    
    # Start the Shiny app as a subprocess
    app_process = subprocess.Popen([r_exe, start_script], 
                                  stdout=subprocess.PIPE, 
                                  stderr=subprocess.PIPE,
                                  text=True)
    
    logger.info("Waiting for app to start...")
    time.sleep(10)  # Give the app time to start
    
    if app_process.poll() is not None:
        # Process has terminated
        stdout, stderr = app_process.communicate()
        logger.error(f"App failed to start: {stderr}")
        sys.exit(1)
    
    logger.info("App started successfully")

def stop_app():
    """Stop the Shiny application"""
    global app_process
    
    if app_process is not None:
        logger.info("Stopping Shiny application...")
        
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
        
        logger.info("App stopped")

# Register the stop_app function to run when the script exits
atexit.register(stop_app)

def run_test():
    """Run the office navigation test"""
    logger.info("Running office navigation test...")
    
    # Get script path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    test_script = os.path.join(script_dir, "office_navigation_test.py")
    
    # Run the test
    result = subprocess.run([sys.executable, test_script], 
                          capture_output=True, text=True)
    
    # Log output
    if result.stdout:
        logger.info(f"Test output:\n{result.stdout}")
    if result.stderr:
        logger.error(f"Test errors:\n{result.stderr}")
    
    # Return the return code
    return result.returncode

if __name__ == "__main__":
    # Make sure the screenshots directory exists
    os.makedirs("screenshots", exist_ok=True)
    
    try:
        # Install R packages
        install_r_packages()
        
        # Start the app
        start_app()
        
        # Run the test
        exit_code = run_test()
        
        # Exit with the test's return code
        sys.exit(exit_code)
    
    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)
    finally:
        # Make sure to stop the app
        stop_app() 