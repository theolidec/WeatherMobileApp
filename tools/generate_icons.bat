@echo off
setlocal

:: Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in PATH
    pause
    exit /b 1
)

:: Check if Pillow is installed
python -c "import PIL" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing Pillow...
    pip install pillow
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install Pillow
        pause
        exit /b 1
    )
)

echo Generating app icons...
python "%~dp0generate_icons.py"

if %ERRORLEVEL% EQU 0 (
    echo Icons generated successfully!
) else (
    echo Failed to generate icons.
)

pause
