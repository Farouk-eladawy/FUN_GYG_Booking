@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ==============================================
echo        GYG System - Auto Push Script (Multi-Repo)
echo ==============================================

:: Define your repositories (Read from config\.env)
set REPO_FTS=
set REPO_SUNNY=
set REPO_NILE=
set REPO_FUN=

if exist "config\.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("config\.env") do (
        if "%%A"=="GITHUB_REPO_FTS" set REPO_FTS=%%B
        if "%%A"=="GITHUB_REPO_SUNNY" set REPO_SUNNY=%%B
        if "%%A"=="GITHUB_REPO_NILE" set REPO_NILE=%%B
        if "%%A"=="GITHUB_REPO_FUN" set REPO_FUN=%%B
    )
)

:: Check .env in root if not found
if "%REPO_FTS%"=="" (
    if exist ".env" (
        for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
            if "%%A"=="GITHUB_REPO_FTS" set REPO_FTS=%%B
            if "%%A"=="GITHUB_REPO_SUNNY" set REPO_SUNNY=%%B
            if "%%A"=="GITHUB_REPO_NILE" set REPO_NILE=%%B
            if "%%A"=="GITHUB_REPO_FUN" set REPO_FUN=%%B
        )
    )
)

:: Trim quotes and spaces
if defined REPO_FTS set REPO_FTS=%REPO_FTS:"=%
if defined REPO_FTS set REPO_FTS=%REPO_FTS: =%
if defined REPO_SUNNY set REPO_SUNNY=%REPO_SUNNY:"=%
if defined REPO_SUNNY set REPO_SUNNY=%REPO_SUNNY: =%
if defined REPO_NILE set REPO_NILE=%REPO_NILE:"=%
if defined REPO_NILE set REPO_NILE=%REPO_NILE: =%
if defined REPO_FUN set REPO_FUN=%REPO_FUN:"=%
if defined REPO_FUN set REPO_FUN=%REPO_FUN: =%

if "%REPO_FTS%"=="" (
    echo [ERROR] Repositories not found in .env or config\.env
    echo Please add GITHUB_REPO_FTS, GITHUB_REPO_SUNNY, etc.
    pause
    exit /b 1
)

:: Ensure git is initialized
if not exist ".git" (
    echo [0/3] Initializing git repository...
    git init
    git branch -M main
)

echo [1/3] Pulling from main repo (FTS) and Adding files...
if defined REPO_FTS (
    git remote set-url origin !REPO_FTS! 2>nul || git remote add origin !REPO_FTS!
    git pull --rebase --autostash origin main || git rebase --abort
)
git add .
echo.

:: Ask for commit message
set "COMMIT_MSG="
set /p COMMIT_MSG="Enter commit message (or press Enter for 'Auto update'): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto update

echo.
echo [2/3] Committing changes...
git commit -m "%COMMIT_MSG%"
echo.

echo [3/3] Pushing to all repositories...
echo.

:: Function to push to a specific repo
if defined REPO_FTS call :PushToRepo "FTS_GYG" "%REPO_FTS%"
if defined REPO_SUNNY call :PushToRepo "Sunny_GYG" "%REPO_SUNNY%"
if defined REPO_NILE call :PushToRepo "Nile_GYG" "%REPO_NILE%"
if defined REPO_FUN call :PushToRepo "FUN_GYG" "%REPO_FUN%"

echo.
echo ==============================================
echo             All Uploads Completed!
echo ==============================================
pause
exit /b 0

:PushToRepo
set "REPO_NAME=%~1"
set "REPO_URL=%~2"

echo ----------------------------------------------
echo Pushing to !REPO_NAME!...
echo URL: !REPO_URL!
echo ----------------------------------------------

:: Push changes directly to the target URL (force to overwrite remote changes)
echo Force pushing to overwrite remote changes...
git push --force "!REPO_URL!" main
echo Done with !REPO_NAME!
echo.
exit /b 0
