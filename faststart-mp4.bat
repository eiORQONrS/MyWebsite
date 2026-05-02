@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM Move the moov atom of every mp4 in public\uploads to the file head
REM (-movflags +faststart). Lossless: -c copy reuses existing streams, so
REM video/audio quality and file size are unchanged.

cd /d "%~dp0"

set "uploads=public\uploads"
set "backup=public\uploads\_backup_pre_faststart"

if not exist "%uploads%" (
    echo [!] %uploads% not found. Run this script from the project root.
    pause
    exit /b 1
)

where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [!] ffmpeg not found in PATH. Install it first:
    echo     winget install ffmpeg
    pause
    exit /b 1
)

if not exist "%backup%" mkdir "%backup%"

set /a count=0
set /a ok=0
set /a fail=0

for %%f in ("%uploads%\*.mp4") do (
    set /a count+=1
    echo [!count!] Processing %%~nxf
    copy /y "%%f" "%backup%\%%~nxf" >nul
    ffmpeg -i "%%f" -c copy -movflags +faststart "%uploads%\__tmp_%%~nxf" -y -loglevel error
    if exist "%uploads%\__tmp_%%~nxf" (
        move /y "%uploads%\__tmp_%%~nxf" "%%f" >nul
        echo     ok
        set /a ok+=1
    ) else (
        echo     FAILED
        set /a fail+=1
    )
)

echo.
echo Done. Total: %count%, ok: %ok%, failed: %fail%
echo Originals backed up to %backup%
pause
