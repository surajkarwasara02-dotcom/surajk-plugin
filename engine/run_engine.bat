@echo off
:: ============================================================================
:: run_engine.bat — Windows launcher for the surajk plugin AI engine
::
:: Usage:
::   run_engine.bat  <image_path>  <output_directory>
::
:: Example:
::   run_engine.bat  "C:\Photos\chair.jpg"  "C:\Users\Me\Documents\sketchup_output"
::
:: The script locates a Python 3 interpreter by checking (in order):
::   1. The bundled runtime at  engine\python\python.exe
::   2. The system PATH (python / python3)
::
:: Requirements:
::   • Python 3.8+ with standard library (no extra packages required for the
::     placeholder stub).  If you integrate a real AI model you may need to
::     run `pip install -r requirements.txt` first — see that file for details.
:: ============================================================================

setlocal enabledelayedexpansion

:: --------------------------------------------------------------------------
:: Resolve the directory that contains this batch file (i.e., engine\).
:: --------------------------------------------------------------------------
set "ENGINE_DIR=%~dp0"
:: Remove trailing backslash from ENGINE_DIR for cleaner path building.
if "%ENGINE_DIR:~-1%"=="\" set "ENGINE_DIR=%ENGINE_DIR:~0,-1%"

:: --------------------------------------------------------------------------
:: Validate arguments
:: --------------------------------------------------------------------------
if "%~1"=="" (
    echo [ERROR] No image path supplied.
    echo Usage: run_engine.bat ^<image_path^> ^<output_directory^>
    exit /b 1
)
if "%~2"=="" (
    echo [ERROR] No output directory supplied.
    echo Usage: run_engine.bat ^<image_path^> ^<output_directory^>
    exit /b 1
)

set "IMAGE_PATH=%~1"
set "OUTPUT_DIR=%~2"

:: --------------------------------------------------------------------------
:: Locate Python interpreter
:: --------------------------------------------------------------------------
set "PYTHON_EXE="

:: 1. Bundled runtime (engine\python\python.exe)
if exist "%ENGINE_DIR%\python\python.exe" (
    set "PYTHON_EXE=%ENGINE_DIR%\python\python.exe"
    echo [INFO] Using bundled Python: !PYTHON_EXE!
    goto :found_python
)

:: 2. System PATH
where python >nul 2>&1
if %errorlevel%==0 (
    set "PYTHON_EXE=python"
    echo [INFO] Using system Python (python).
    goto :found_python
)

where python3 >nul 2>&1
if %errorlevel%==0 (
    set "PYTHON_EXE=python3"
    echo [INFO] Using system Python (python3).
    goto :found_python
)

echo [ERROR] Python not found.
echo         Install Python 3.8+ and ensure it is on your PATH,
echo         or place a Python runtime in: %ENGINE_DIR%\python\
exit /b 1

:found_python

:: --------------------------------------------------------------------------
:: Run the engine
:: --------------------------------------------------------------------------
echo [INFO] Launching engine...
echo [INFO]   Image  : "%IMAGE_PATH%"
echo [INFO]   Output : "%OUTPUT_DIR%"

"%PYTHON_EXE%" "%ENGINE_DIR%\engine.py" --image "%IMAGE_PATH%" --output "%OUTPUT_DIR%"

set "EXIT_CODE=%errorlevel%"

if %EXIT_CODE% neq 0 (
    echo [ERROR] Engine exited with code %EXIT_CODE%.
    exit /b %EXIT_CODE%
)

echo [OK] Engine finished successfully.
exit /b 0
