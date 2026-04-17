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

if defined REPO_FTS set REPO_FTS=%REPO_FTS:"=%
if defined REPO_FTS set REPO_FTS=%REPO_FTS: =%
if defined REPO_SUNNY set REPO_SUNNY=%REPO_SUNNY:"=%
if defined REPO_SUNNY set REPO_SUNNY=%REPO_SUNNY: =%
if defined REPO_NILE set REPO_NILE=%REPO_NILE:"=%
if defined REPO_NILE set REPO_NILE=%REPO_NILE: =%
if defined REPO_FUN set REPO_FUN=%REPO_FUN:"=%
if defined REPO_FUN set REPO_FUN=%REPO_FUN: =%

if defined REPO_FTS echo call FTS
if defined REPO_SUNNY echo call SUNNY
if defined REPO_NILE echo call NILE
if defined REPO_FUN echo call FUN

