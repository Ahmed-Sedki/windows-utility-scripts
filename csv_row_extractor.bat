@echo off
REM Check if all three parameters are provided.
if "%~3"=="" (
    echo Usage: %~n0 input.csv output.csv number_of_rows
    exit /b 1
)

set "input=%~1"
set "output=%~2"
set "rows=%~3"

setlocal enabledelayedexpansion
set count=0

REM Redirect the output of the loop into the output file.
> "%output%" (
  for /f "usebackq delims=" %%a in ("%input%") do (
    set /a count+=1
    if !count! leq %rows% (
      echo %%a
    )
  )
)
endlocal

echo Extracted %rows% rows from '%input%' to '%output%'.
