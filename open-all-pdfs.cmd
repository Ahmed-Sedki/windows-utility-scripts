@echo off
setlocal enabledelayedexpansion

REM Check if there are any PDF files in the current directory
set pdf_count=0
for %%F in (*.pdf) do set /a pdf_count+=1

REM If no PDFs found, show a message
if %pdf_count%==0 (
    echo No PDF files found in the current directory.
    pause
    exit /b
)

REM Open all PDF files
for %%F in (*.pdf) do (
    start "" "%%F"
)