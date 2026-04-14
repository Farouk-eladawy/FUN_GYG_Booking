@echo off
setlocal
cd /d "%~dp0"

echo Starting GYG System with 3-page limit...
echo.

REM Set the maximum pages to scan per cycle to 3
set MAX_PAGES=3

REM Use a separate database file for this quick sync
set DATABASE_PATH=bookings_3pages.db

REM Activate the virtual environment
if exist venv\Scripts\activate (
    call venv\Scripts\activate
) else (
    echo Virtual environment not found. Trying global python...
)

REM Run the script in server mode (continuous sync)
python gyg_unified.py --server

pause
