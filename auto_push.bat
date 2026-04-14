@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ==============================================
echo        GYG System - Auto Push Script
echo ==============================================

set REPO_URL=

:: Check config\.env first
if exist "config\.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("config\.env") do (
        if "%%A"=="GITHUB_REPO_URL" set REPO_URL=%%B
    )
)

:: Check .env in root if not found
if "%REPO_URL%"=="" (
    if exist ".env" (
        for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
            if "%%A"=="GITHUB_REPO_URL" set REPO_URL=%%B
        )
    )
)

:: Trim quotes and spaces if any
if defined REPO_URL set REPO_URL=%REPO_URL:"=%
if defined REPO_URL set REPO_URL=%REPO_URL: =%

if "%REPO_URL%"=="" (
    echo [ERROR] GITHUB_REPO_URL not found in .env or config\.env
    echo Please add GITHUB_REPO_URL=https://github.com/your-username/repo.git
    pause
    exit /b 1
)

echo Found Repository URL: %REPO_URL%
echo.

:: Ensure git is initialized
if not exist ".git" (
    echo [0/4] Initializing git repository...
    git init
    git branch -M main
)

:: Ensure origin is set correctly
git remote set-url origin %REPO_URL% 2>nul || git remote add origin %REPO_URL%

echo [1/4] Adding files...
git add .
echo.

:: Ask for commit message
set "COMMIT_MSG="
set /p COMMIT_MSG="Enter commit message (or press Enter for 'Auto update'): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto update

echo.
echo [2/4] Committing changes...
git commit -m "%COMMIT_MSG%"
echo.

echo [3/4] Pulling latest changes from remote (rebase)...
:: Check if the remote has a main branch
git ls-remote --exit-code --heads origin main >nul 2>&1
if errorlevel 1 (
    echo Remote branch 'main' not found. Skipping pull.
) else (
    git pull --rebase origin main
)
echo.

echo [4/4] Pushing to remote repository...
git push -u origin main

echo.
echo ==============================================
echo             Upload Completed!
echo ==============================================
pause
