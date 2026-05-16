@echo off
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RESET=%ESC%[0m"

echo.
echo ===================================
echo Modpack Server Setup Script
echo Made by LithumC, MIT License
echo Version 2.1, released on 2026-05-16
echo ===================================
echo.

:: 1. Download mrpack-install
echo If the download is too slow or fails, use vpn or a different network connection.
echo or download mrpack-install.exe manually from,need v0.16.10 or later.
if exist mrpack-install-windows.exe (
    echo mrpack-install-windows.exe already exists, skipping download.
) else (
    echo %YELLOW%Downloading mrpack-install-windows...%RESET%
    curl -L -o mrpack-install-windows.exe "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-windows.exe"
)

:: 2. Download Forge installer
echo If the download is too slow or fails, use vpn or a different network connection.
echo or download forge-installer.jar manually from,need forge 1.20.1-47.4.13 installer.
if exist Forge-1.20.1-47.4.13.jar (
    echo Forge-1.20.1-47.4.13.jar already exists, skipping download.
) else (
    echo %YELLOW%Downloading Forge installer...%RESET%
    curl -L -o Forge-1.20.1-47.4.13.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
)

:: 3. Install Forge server
echo Run this script with java 17 or later, and make sure java is in your PATH.
echo %YELLOW%Installing Forge server...%RESET%
java -jar Forge-1.20.1-47.4.13.jar --installServer

:: 4. Deploy modpack
echo If the download is too slow or fails, use vpn or a different network connection.
echo %YELLOW%Deploying modpack...%RESET%
mrpack-install-windows.exe UeU522Qh 19.3.142-Canary --server-dir . --server-file libraries\net\minecraftforge\forge\1.20.1-47.4.13\forge-1.20.1-47.4.13-universal.jar

:: 5. Remove client-only mods
echo %YELLOW%Removing client-only mods...%RESET%
for /f "usebackq delims=" %%i in (".modremover") do (
    if exist "mods\%%i" del "mods\%%i"
)

:: 6. Cleanup
echo %YELLOW%Cleaning up...%RESET%
goto skip_cleanup
del Forge-1.20.1-47.4.13.jar
del Forge-1.20.1-47.4.13.jar.log
:skip_cleanup

:: 7. Remove client-only resourcepacks and shaderpacks
echo %YELLOW%Removing client-only resourcepacks and shaderpacks...%RESET%
del "resourcepacks\ClickSound.zip"
del "resourcepacks\Dark Smooth GUI.zip"
del "resourcepacks\Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip"
rd /s /q "shaderpacks"
echo.

echo %GREEN%Done. Run run.bat to start the server.%RESET%
pause