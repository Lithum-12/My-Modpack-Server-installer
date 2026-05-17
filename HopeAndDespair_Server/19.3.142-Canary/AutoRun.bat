@echo off
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[96m"
set "RED=%ESC%[91m"
set "RESET=%ESC%[0m"

echo.
echo %BLUE%======================================%RESET%
echo %BLUE%  Modpack Server Setup Script%RESET%
echo %BLUE%  Made by LithumC ^| MIT License%RESET%
echo %BLUE%  Version 2.8 ^| 2026-05-17%RESET%
echo %BLUE%  Supported: HAD 19.3.142-Canary%RESET%
echo %BLUE%======================================%RESET%
echo.
echo Current modpack version: HAD 19.3.142-Canary
echo.
set /p CONFIRM=Proceed with installation? [Y/N]: 
if /i "%CONFIRM%"=="Y" goto start
if /i "%CONFIRM%"=="N" goto abort
echo Invalid input, please enter Y or N.
goto abort

:abort
echo Installation cancelled.
pause & exit /b 0

:start

:: 1. Download mrpack-install
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Or download mrpack-install-windows.exe manually, need v0.16.10 or later.%RESET%
if exist mrpack-install-windows.exe (
    echo mrpack-install-windows.exe already exists, skipping download.
) else (
    echo %YELLOW%Downloading mrpack-install-windows...%RESET%
    curl -fL -o mrpack-install-windows.exe "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-windows.exe"
    if errorlevel 1 (
        echo %RED%Failed: Could not download mrpack-install-windows.exe%RESET%
        pause & exit /b 1
    )
)
echo.

:: 2. Download Forge installer
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Or download forge-1.20.1-47.4.13-installer.jar manually, need Forge 1.20.1-47.4.13 installer.%RESET%
if exist forge-1.20.1-47.4.13-installer.jar (
    echo forge-1.20.1-47.4.13-installer.jar already exists, skipping download.
) else (
    echo %YELLOW%Downloading Forge installer...%RESET%
    curl -fL -o forge-1.20.1-47.4.13-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
    if errorlevel 1 (
        echo %RED%Failed: Could not download Forge installer.%RESET%
        pause & exit /b 1
    )
)
echo.

:: 3. Install Forge server
echo %YELLOW%Run this script with Java 17 or later, and make sure java is in your PATH.%RESET%
echo %YELLOW%Installing Forge server...%RESET%
java -jar forge-1.20.1-47.4.13-installer.jar --installServer
if errorlevel 1 (
    echo %RED%Failed: Forge installation failed. Make sure Java 17+ is installed and in PATH.%RESET%
    pause & exit /b 1
)
echo.

:: 4. Deploy modpack
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Deploying modpack...%RESET%
if exist "Hope and despair 19.3.142-Canary.mrpack" (
    echo Modpack file already exists, deploying from local file.
    mrpack-install-windows.exe "Hope and despair 19.3.142-Canary.mrpack" --server-dir . --server-file libraries\net\minecraftforge\forge\1.20.1-47.4.13\forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    type mrpack-deploy.log
) else (
    mrpack-install-windows.exe UeU522Qh 19.3.142-Canary --server-dir . --server-file libraries\net\minecraftforge\forge\1.20.1-47.4.13\forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    type mrpack-deploy.log
    if not exist "Hope and despair 19.3.142-Canary.mrpack" goto mrpack_failed
)
goto mrpack_check
:mrpack_failed
echo %RED%Failed: Modpack file download failed. Check your network connection.%RESET%
del mrpack-deploy.log
pause & exit /b 1
:mrpack_check
findstr /i "Download failed" mrpack-deploy.log >nul
if not errorlevel 1 (
    echo %YELLOW%Warn: One or more files failed to download, server may be missing some mods or configs.%RESET%
    echo %YELLOW%Re-run the script to retry, already downloaded files will be skipped.%RESET%
)
del mrpack-deploy.log
echo.

:: 5. Remove client-only mods
echo %YELLOW%Removing client-only mods...%RESET%
if not exist ".modremover" (
    echo %RED%Failed: .modremover file not found.%RESET%
    pause & exit /b 1
)
for /f "usebackq delims=" %%i in (".modremover") do (
    if exist "mods\%%i" del "mods\%%i"
)
echo.

:: 6. Cleanup
goto skip_cleanup
echo %YELLOW%Cleaning up...%RESET%
del forge-1.20.1-47.4.13-installer.jar
del forge-1.20.1-47.4.13-installer.jar.log
:skip_cleanup
echo.

:: 7. Remove client-only resourcepacks and shaderpacks
echo %YELLOW%Removing client-only resourcepacks and shaderpacks...%RESET%
del "resourcepacks\ClickSound.zip"
del "resourcepacks\Dark Smooth GUI.zip"
del "resourcepacks\Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip"
rd /s /q "shaderpacks"
echo.

echo %GREEN%Done. Run run.bat to start the server.%RESET%
pause