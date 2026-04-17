@echo off
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
echo FTS: %REPO_FTS%
echo SUNNY: %REPO_SUNNY%
echo NILE: %REPO_NILE%
echo FUN: %REPO_FUN%

