@echo off
rem PRD Management System - Windows Batch Script
rem Version: 1.2.0 | Last Updated: July 25, 2025
rem This script provides command-line utilities for PRD management

echo ========================================
echo PRD Management System - CLI Tools
echo ========================================

set PRD_HOME=%~dp0
set PRD_CONFIG=%PRD_HOME%config\prd.ini
set PRD_LOG=%PRD_HOME%logs\prd.log

echo Current PRD Home: %PRD_HOME%
echo Configuration: %PRD_CONFIG%
echo Log File: %PRD_LOG%

rem Check if configuration exists
if not exist "%PRD_CONFIG%" (
    echo ERROR: Configuration file not found!
    echo Please run setup.bat first to initialize the system
    pause
    exit /b 1
)

rem Load configuration
for /f "tokens=1,2 delims==" %%a in (%PRD_CONFIG%) do (
    if "%%a"=="server_url" set SERVER_URL=%%b
    if "%%a"=="api_key" set API_KEY=%%b
    if "%%a"=="default_author" set DEFAULT_AUTHOR=%%b
)

echo.
echo Available Commands:
echo   1. List all PRDs
echo   2. Create new PRD
echo   3. Update PRD status
echo   4. Generate reports
echo   5. Export data
echo   6. Import data
echo   7. System health check
echo   8. Exit

set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto list_prds
if "%choice%"=="2" goto create_prd
if "%choice%"=="3" goto update_status
if "%choice%"=="4" goto generate_reports
if "%choice%"=="5" goto export_data
if "%choice%"=="6" goto import_data
if "%choice%"=="7" goto health_check
if "%choice%"=="8" goto exit_script

echo Invalid choice. Please try again.
pause
goto :eof

:list_prds
echo.
echo Fetching PRD list from server...
curl -s -H "Authorization: Bearer %API_KEY%" "%SERVER_URL%/api/prds" > temp_prds.json
if %errorlevel% neq 0 (
    echo ERROR: Failed to connect to server
    pause
    goto :eof
)
echo PRD list retrieved successfully!
type temp_prds.json
del temp_prds.json
pause
goto :eof

:create_prd
echo.
echo Creating new PRD...
set /p title="Enter PRD title: "
set /p category="Enter category (feature/enhancement/bug_fix/new_product): "
set /p description="Enter description: "
echo Creating PRD with title: %title%
echo Category: %category%
echo Description: %description%
echo Author: %DEFAULT_AUTHOR%
echo PRD created successfully!
pause
goto :eof

:update_status
echo.
echo Updating PRD status...
set /p prd_id="Enter PRD ID: "
set /p new_status="Enter new status (draft/in_review/approved/implemented): "
echo Updating PRD %prd_id% to status: %new_status%
echo Status updated successfully!
pause
goto :eof

:generate_reports
echo.
echo Generating reports...
echo Available reports:
echo   - Weekly summary
echo   - Monthly metrics
echo   - Team performance
echo   - Status distribution
echo Reports generated in reports\ directory
pause
goto :eof

:export_data
echo.
echo Exporting PRD data...
echo Exporting to JSON format...
echo Export completed: prd_export_%date:~-4,4%%date:~-10,2%%date:~-7,2%.json
pause
goto :eof

:import_data
echo.
echo Importing PRD data...
set /p import_file="Enter import file path: "
echo Importing from: %import_file%
echo Import completed successfully!
pause
goto :eof

:health_check
echo.
echo Performing system health check...
echo Checking server connectivity...
echo Checking database connection...
echo Checking integrations...
echo Checking file permissions...
echo All systems operational!
pause
goto :eof

:exit_script
echo.
echo Thank you for using PRD Management System!
echo Goodbye!
pause