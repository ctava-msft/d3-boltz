@echo off
REM Quick Setup and Run Script for BoltzDesign1 on Windows
REM This batch file automates the entire setup and first run

echo ========================================
echo BoltzDesign1 Quick Setup
echo ========================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.10+ from https://www.python.org/
    pause
    exit /b 1
)

echo Step 1/4: Checking system requirements...
python check_requirements.py
if errorlevel 1 (
    echo.
    echo WARNING: Some requirements not met
    echo You can continue but may encounter issues
    echo.
    pause
)

echo.
echo Step 2/4: Setting up environment (this will take 15-30 minutes)...
echo.
python setup_environment.py
if errorlevel 1 (
    echo.
    echo ERROR: Setup failed
    pause
    exit /b 1
)

echo.
echo Step 3/4: Activating virtual environment...
call boltz_venv\Scripts\activate.bat

echo.
echo Step 4/4: Ready to generate binders!
echo.
echo You can now run:
echo   python run_binder_generation.py
echo.
echo Or run a quick test:
echo   python run_binder_generation.py --design_samples 1 --no-alphafold
echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.

REM Ask if user wants to run now
set /p RUN_NOW="Do you want to run binder generation now? (y/n): "
if /i "%RUN_NOW%"=="y" (
    echo.
    echo Starting binder generation with default settings...
    echo This may take 1-2 hours depending on your GPU...
    echo.
    python run_binder_generation.py
)

echo.
echo Virtual environment is still active.
echo To deactivate, type: deactivate
echo.
pause
