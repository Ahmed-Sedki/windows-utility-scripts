@echo off
setlocal enabledelayedexpansion

:: Configuration Section
set "config_file=%~dp0file_opener_config.ini"

:: Load user configurations
if exist "%config_file%" (
    for /f "tokens=1,2 delims==" %%a in (%config_file%) do (
        if "%%a"=="default_directory" set "user_directory=%%b"
    )
)

:: Default to script's directory if no custom directory set
if "%user_directory%"=="" set "user_directory=%~dp0"

:menu
cls
echo ===================================
echo ADVANCED FILE OPENER UTILITY
echo ===================================
echo Current Directory: %user_directory%
echo.
echo MENU:
echo 1. Open PDF Files
echo 2. Open Word Documents
echo 3. Open Excel Files
echo 4. Open PowerPoint Files
echo 5. Open Text Files
echo 6. Open Image Files
echo 7. Change Working Directory
echo 8. Search Files
echo 9. Exit
echo.

set /p choice="Enter your choice (1-9): "

:: File Type Mapping
if "%choice%"=="1" (
    set "extension=*.pdf"
    set "filetype=PDF"
    goto openfiles
)
if "%choice%"=="2" (
    set "extension=*.doc* *.docm"
    set "filetype=Word"
    goto openfiles
)
if "%choice%"=="3" (
    set "extension=*.xls* *.xlsm"
    set "filetype=Excel"
    goto openfiles
)
if "%choice%"=="4" (
    set "extension=*.ppt* *.pptm"
    set "filetype=PowerPoint"
    goto openfiles
)
if "%choice%"=="5" (
    set "extension=*.txt *.log *.md"
    set "filetype=Text"
    goto openfiles
)
if "%choice%"=="6" (
    set "extension=*.jpg *.jpeg *.png *.gif *.bmp *.tiff"
    set "filetype=Image"
    goto openfiles
)
if "%choice%"=="7" (
    goto change_directory
)
if "%choice%"=="8" (
    goto search_files
)
if "%choice%"=="9" (
    echo Exiting the File Opener Utility.
    exit /b
)

echo Invalid choice. Press any key to continue...
pause >nul
goto menu

:openfiles
cls
:: Change to user-specified directory
pushd "%user_directory%"

echo Opening all %filetype% files in %user_directory%...
echo.

set "count=0"
set "opened_files="
for %%F in (%extension%) do (
    start "" "%%F"
    set /a count+=1
    set "opened_files=!opened_files! %%F,"
)

:: Log the file opens
if %count% gtr 0 (
    echo %date% %time%: Opened %count% %filetype% files: %opened_files% >> "%log_file%"
    echo Opened %count% %filetype% files.
) else (
    echo No %filetype% files found in the current directory.
)

:: Return to original directory
popd

echo.
pause
goto menu

:change_directory
cls
echo Current Directory: %user_directory%
echo.
set /p new_directory="Enter full path to new working directory: "

:: Validate directory
if exist "%new_directory%\" (
    set "user_directory=%new_directory%"
    
    :: Save to config file
    (
        echo default_directory=%new_directory%
    ) > "%config_file%"
    
    echo Directory changed successfully.
) else (
    echo Invalid directory. Please check the path and try again.
)
pause
goto menu

:view_log
cls
echo Recent File Open History:
echo.
if exist "%log_file%" (
    type "%log_file%"
) else (
    echo No log file found.
)
echo.
pause
goto menu

:search_files
cls
echo FILE SEARCH UTILITY
echo.
set /p search_term="Enter search term or file extension (e.g., .pdf or report): "

echo Searching for files matching "%search_term%"...
echo.

set "found_count=0"
for /r "%user_directory%" %%F in (*%search_term%*) do (
    echo %%F
    set /a found_count+=1
)

if %found_count%==0 (
    echo No files found matching "%search_term%".
) else (
    echo.
    echo Found %found_count% matching files.
)

echo.
pause
goto menu