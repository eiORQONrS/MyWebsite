@echo off
chcp 65001 >nul

REM Extract one frame at t=1s from every mp4 in public\uploads as a jpg
REM poster, saved to public\uploads\posters\<basename>.jpg
REM
REM The poster is shown by <video poster="..."> when autoplay is blocked
REM (e.g., in WeChat's X5 browser, or when the .cn build skips video src).

cd /d "%~dp0"

set "uploads=public\uploads"
set "posters=public\uploads\posters"

if not exist "%uploads%" (
    echo [!] %uploads% not found. Run from project root.
    pause
    exit /b 1
)

where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [!] ffmpeg not found in PATH.
    pause
    exit /b 1
)

if not exist "%posters%" mkdir "%posters%"

for %%f in ("%uploads%\*.mp4") do call :process "%%f"

echo.
echo Done.
pause
exit /b 0

:process
set "in=%~1"
set "name=%~n1"
set "out=%posters%\%name%.jpg"
echo Processing: %name%.mp4
ffmpeg -ss 00:00:01 -i "%in%" -vframes 1 -q:v 3 -vf "scale='min(1280,iw)':-2" -y "%out%" -loglevel error
if exist "%out%" (
    echo     ok
    exit /b 0
)
REM fallback: try frame 0 if the 1s seek failed (very short clips)
ffmpeg -i "%in%" -vframes 1 -q:v 3 -vf "scale='min(1280,iw)':-2" -y "%out%" -loglevel error
if exist "%out%" (
    echo     ok ^(frame 0^)
) else (
    echo     FAILED
)
exit /b 0
