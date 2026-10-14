@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  release.bat
REM  1) Re-scrape Icy Veins data (FromClassCodex/update-data flow)
REM  2) Stage data + media changes
REM  3) Bump version (last segment +1), commit, tag, push
REM  4) Build release zip via `git archive HEAD` and create a
REM     GitHub release (gh release create)
REM
REM  Usage:
REM    release.bat          release only if data/ changed
REM    release.bat --force  release even if data/ is unchanged
REM
REM  Requires: git, gh (logged in via `gh auth login`)
REM ============================================================

set "ROOT=%~dp0"
cd /d "%ROOT%"

echo ============================================
echo  MythicPlusLootTracker - data update ^& release
echo ============================================
echo.

REM ---- 1. Re-scrape data (same flow as FromClassCodex/update-data.bat) ----
cd /d "%ROOT%FromClassCodex\apps\service"
if not exist "node_modules\" (
    echo [1/4] Installing dependencies...
    call corepack pnpm install
    if errorlevel 1 (
        echo.
        echo FAILED: pnpm install - aborting.
        goto :end
    )
)
echo [1/4] Running pnpm sync (re-scrape Icy Veins)...
call corepack pnpm sync
if errorlevel 1 (
    echo.
    echo FAILED: pnpm sync - data was NOT updated. Aborting.
    goto :end
)
cd /d "%ROOT%"

echo.
echo [2/4] Checking for changes...
git add data\db_icyveins.lua data\Generated.lua

REM Stage the media icon so it ships in the release zip (git archive only
REM includes tracked files). Safe to run even if already tracked.
git add media\icy-veins.png 2>nul

REM Was anything staged in data\?
git diff --cached --quiet -- data\
set "dataChanged=!errorlevel!"

if "!dataChanged!"=="0" (
    if not "%~1"=="--force" (
        echo.
        echo No data changes after sync. Nothing to release.
        echo Run again with:  release.bat --force   to release anyway.
        goto :end
    )
    echo.
    echo [--force] No data changes, but releasing anyway.
)

REM ---- 3. Bump version (last segment +1) ----
set "ver="
for /f "tokens=2 delims=:" %%v in ('findstr /b /c:"## Version" MythicPlusLootTracker.toc') do set "ver=%%v"
for /f "tokens=* delims= " %%c in ("!ver!") do set "ver=%%c"
if not defined ver (
    echo FAILED: could not read ## Version from .toc. Aborting.
    goto :end
)
echo Current version: !ver!

REM Split into segments, bump the last one, rejoin with ".".
set "n=0"
for /f "tokens=1-10 delims=." %%a in ("!ver!") do (
    set /a "n+=1" & set "seg[!n!]=%%a"
    if not "%%b"=="" set /a "n+=1" & set "seg[!n!]=%%b"
    if not "%%c"=="" set /a "n+=1" & set "seg[!n!]=%%c"
)
set /a "seg[!n!]+=1"
set "newver=!seg[1]!"
for /l %%i in (2,1,!n!) do set "newver=!newver!.!seg[%%i]!"
echo New version:     !newver!

REM Write the bumped version back into the .toc.
powershell -NoProfile -Command "(Get-Content 'MythicPlusLootTracker.toc') -replace '^## Version: .*', '## Version: !newver!' | Set-Content 'MythicPlusLootTracker.toc'"

git add MythicPlusLootTracker.toc media\icy-veins.png 2>nul

echo.
echo [3/4] Committing and tagging !newver!...
git commit -m "chore: bump version to !newver!"
if errorlevel 1 (
    echo FAILED: git commit - aborting.
    goto :end
)

git tag "v!newver!"
if errorlevel 1 (
    echo FAILED: git tag - v!newver! may already exist. Aborting.
    goto :end
)

echo.
echo [3/4] Pushing to origin...
git push origin main
if errorlevel 1 (
    echo FAILED: git push origin main - aborting.
    goto :end
)
git push origin "v!newver!"
if errorlevel 1 (
    echo FAILED: git push origin v!newver! - tag not pushed.
    goto :end
)

REM ---- 4. Build release zip and create GitHub release ----
echo.
echo [4/4] Building release zip and creating GitHub release...
set "zipname=MythicPlusLootTracker-v!newver!.zip"

REM git archive HEAD exports tracked files only (FromClassCodex/ is
REM gitignored, so it never lands in the zip).
git archive --format=zip --output "!zipname!" HEAD
if errorlevel 1 (
    echo FAILED: git archive - zip not built.
    goto :end
)

if not exist "!zipname!" (
    echo FAILED: zip file was not created. Aborting.
    goto :end
)

REM Create the GitHub release and attach the zip.
gh release create "v!newver!" "!zipname!" --title "v!newver!" --generate-notes
if errorlevel 1 (
    echo.
    echo WARNING: gh release create failed.
    echo Tag v!newver! was pushed; create the release manually:
    echo   gh release create v!newver! !zipname! --title "v!newver!" --generate-notes
    echo Make sure you are logged in:  gh auth login
) else (
    echo.
    echo ============================================
    echo  Release v!newver! created successfully.
    echo  Tag v!newver! pushed; zip: !zipname!
    echo ============================================
)

REM Clean up the local zip after the release is created.
if exist "!zipname!" del /q "!zipname!"

:end
endlocal
echo.
pause