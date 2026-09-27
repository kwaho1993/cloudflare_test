@echo off
setlocal

pushd "%~dp0.."
if errorlevel 1 exit /b 1

if not exist package.json goto :missing_project
if not exist node_modules goto :missing_dependencies

if not exist .wrangler mkdir .wrangler

set "EXPORT_FILE=./.wrangler/remote-d1.sql"
set "EXPORT_LOG=./.wrangler/d1-export.log"
set "SNAPSHOT_DIR=.wrangler\remote-copy-%RANDOM%-%RANDOM%"

echo Exporting the remote D1 database...
call npx wrangler d1 export DB --remote --output=%EXPORT_FILE% --skip-confirmation > "%EXPORT_LOG%" 2>&1
set "EXPORT_EXIT=%ERRORLEVEL%"

powershell -NoProfile -Command "$log = Get-Content -LiteralPath '.wrangler\d1-export.log' -Raw; $log = [regex]::Replace($log, 'https://[^\s]+', '[temporary export URL hidden]'); [Console]::Write($log)"
powershell -NoProfile -Command "Clear-Content -LiteralPath '.wrangler\d1-export.log'"
if not "%EXPORT_EXIT%"=="0" goto :failed

if not exist "%SNAPSHOT_DIR%" mkdir "%SNAPSHOT_DIR%"
echo Importing into isolated local storage: %SNAPSHOT_DIR%
call npx wrangler d1 execute DB --local --persist-to="%SNAPSHOT_DIR%" --file=%EXPORT_FILE%
if errorlevel 1 goto :failed

echo Building Astro pages...
call npm run build
if errorlevel 1 goto :failed

echo Starting the Worker locally. Open http://127.0.0.1:8787
echo This run uses a local snapshot; changes will not be written to remote D1.
call npx wrangler dev --ip 127.0.0.1 --port 8787 --persist-to="%SNAPSHOT_DIR%"
set "DEV_EXIT=%ERRORLEVEL%"

popd
exit /b %DEV_EXIT%

:missing_project
echo Could not find package.json. Run this file from the project's for_dev folder.
goto :failed

:missing_dependencies
echo Dependencies are missing. Run npm install in the project folder first.
goto :failed

:failed
echo The local D1 development server could not be started.
pause
popd
exit /b 1
