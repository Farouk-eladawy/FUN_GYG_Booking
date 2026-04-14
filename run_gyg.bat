@echo off
setlocal
cd /d "%~dp0"

echo Starting GYG System (Standard Mode)...
echo.

REM Use the main database file for full sync
set DATABASE_PATH=bookings.db

REM Activate the virtual environment
if exist venv\Scripts\activate (
    call venv\Scripts\activate
) else (
    echo Virtual environment not found. Trying global python...
)

REM Run the script in server mode (continuous sync)
python gyg_unified.py --server

pause
