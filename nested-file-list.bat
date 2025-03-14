@echo off
setlocal enabledelayedexpansion
set "output_file=%USERPROFILE%\Desktop\file_list.txt"
if exist "%output_file%" del "%output_file%"
echo File Name List > "%output_file%"
echo =============== >> "%output_file%"

REM List files in the current directory
for %%F in (*.*) do (
    echo %%~nxF >> "%output_file%"
)

REM Recursively list files in subdirectories
for /R %%F in (*.*) do (
    echo %%F >> "%output_file%"
)

echo File list has been saved to the desktop as file_list.txt
pause