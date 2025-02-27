@echo off
setlocal enabledelayedexpansion

set "output_file=%USERPROFILE%\Desktop\file_list.txt"

if exist "%output_file%" del "%output_file%"

echo File Name List > "%output_file%"
echo =============== >> "%output_file%"

for %%F in (*.*) do (
    echo %%~nxF >> "%output_file%"
)

echo File list has been saved to the desktop as file_list.txt
pause