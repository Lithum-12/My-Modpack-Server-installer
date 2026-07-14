@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[96m"
set "RED=%ESC%[91m"
set "RESET=%ESC%[0m"

echo.
echo %BLUE%+---------------------------------+%RESET%
echo %BLUE%^|  Hope and Despair             ^|%RESET%
echo %BLUE%^|  Server Setup Script v3.6     ^|%RESET%
echo %BLUE%^|  Made by LithumC              ^|%RESET%
echo %BLUE%^|  CC BY-NC 4.0 License         ^|%RESET%
echo %BLUE%+---------------------------------+%RESET%
echo.
echo Current modpack version: %YELLOW%HAD 19.4.159%RESET%
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
set "LOG_FILE=autorun.log"
echo AutoRun.bat v3.6 - %DATE% %TIME% > "!LOG_FILE!"
echo Modpack: Hope and despair 19.4.159 >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

:: 0. Check Java version and JDK/JRE
echo %YELLOW%Checking Java version...%RESET%
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do set "JAVA_VER_RAW=%%v"
set "JAVA_VER_RAW=!JAVA_VER_RAW:"=!"
for /f "tokens=1 delims=." %%m in ("!JAVA_VER_RAW!") do set "JAVA_MAJOR=%%m"
if !JAVA_MAJOR! LSS 17 (
    echo %RED%Failed: Java !JAVA_VER_RAW! detected, Java 17 or later is required.%RESET%
    echo [0] Failed: Java !JAVA_VER_RAW! detected, Java 17+ required. >> "!LOG_FILE!"
    pause & exit /b 1
)
echo Java !JAVA_VER_RAW! detected, OK.
echo [0] Java !JAVA_VER_RAW! detected, OK. >> "!LOG_FILE!"
javac -version >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%Warn: JDK not detected, you may be using JRE. High version JRE may cause compatibility issues, JDK is recommended.%RESET%
    echo [0] Warn: JDK not detected, possibly using JRE. >> "!LOG_FILE!"
)
echo.

:: 1. Download mrpack-install
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Or download mrpack-install-windows.exe manually, need v0.16.10 or later.%RESET%
if exist mrpack-install-windows.exe (
    echo mrpack-install-windows.exe already exists, skipping download.
    echo [1] mrpack-install-windows.exe already exists, skipping download. >> "!LOG_FILE!"
) else (
    echo %YELLOW%Downloading mrpack-install-windows...%RESET%
    echo [1] Downloading mrpack-install-windows... >> "!LOG_FILE!"
    curl -fL --ssl-no-revoke -o mrpack-install-windows.exe "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-windows.exe"
    if errorlevel 1 (
        echo %RED%Failed: Could not download mrpack-install-windows.exe%RESET%
        echo [1] Failed: Could not download mrpack-install-windows.exe >> "!LOG_FILE!"
        pause & exit /b 1
    )
    echo [1] mrpack-install-windows.exe downloaded successfully. >> "!LOG_FILE!"
)
echo.

:: 2. Download Forge installer
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Or download forge-1.20.1-47.4.13-installer.jar manually, need Forge 1.20.1-47.4.13 installer.%RESET%
if exist forge-1.20.1-47.4.13-installer.jar (
    echo forge-1.20.1-47.4.13-installer.jar already exists, skipping download.
    echo [2] forge-1.20.1-47.4.13-installer.jar already exists, skipping download. >> "!LOG_FILE!"
) else (
    echo %YELLOW%Downloading Forge installer...%RESET%
    echo [2] Downloading Forge installer... >> "!LOG_FILE!"
    curl -fL --ssl-no-revoke -o forge-1.20.1-47.4.13-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
    if errorlevel 1 (
        echo %RED%Failed: Could not download Forge installer.%RESET%
        echo [2] Failed: Could not download Forge installer. >> "!LOG_FILE!"
        pause & exit /b 1
    )
    echo [2] Forge installer downloaded successfully. >> "!LOG_FILE!"
)
echo.

:: 3. Install Forge server
echo %YELLOW%Run this script with Java 17 or later, and make sure java is in your PATH.%RESET%
echo %YELLOW%Installing Forge server, this may take a few minutes...%RESET%
echo %YELLOW%Full output is being written to autorun.log%RESET%
echo [3] Installing Forge server... >> "!LOG_FILE!"
java -jar forge-1.20.1-47.4.13-installer.jar --installServer >> "!LOG_FILE!" 2>&1
if errorlevel 1 (
    echo %RED%Failed: Forge installation failed. Make sure Java 17+ is installed and in PATH.%RESET%
    echo [3] Failed: Forge installation failed. >> "!LOG_FILE!"
    pause & exit /b 1
)
echo [3] Forge installed successfully. >> "!LOG_FILE!"
echo.

:: 4. Deploy modpack
echo %YELLOW%If the download is too slow or fails, use vpn or a different network connection.%RESET%
echo %YELLOW%Deploying modpack...%RESET%
echo [4] Deploying modpack... >> "!LOG_FILE!"
if exist "Hope and despair 19.4.159.mrpack" (
    echo Modpack file already exists, deploying from local file.
    echo %YELLOW%Warn: If you did not run this script as administrator, a UAC prompt may appear now.%RESET%
    echo [4] Deploying from local file. >> "!LOG_FILE!"
    mrpack-install-windows.exe "Hope and despair 19.4.159.mrpack" --server-dir . --server-file libraries\net\minecraftforge\forge\1.20.1-47.4.13\forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    set MRPACK_ERR=!ERRORLEVEL!
    type mrpack-deploy.log
    type mrpack-deploy.log >> "!LOG_FILE!"
    if !MRPACK_ERR! neq 0 goto mrpack_failed
) else (
    mrpack-install-windows.exe UeU522Qh 19.4.159 --server-dir . --server-file libraries\net\minecraftforge\forge\1.20.1-47.4.13\forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    set MRPACK_ERR=!ERRORLEVEL!
    type mrpack-deploy.log
    type mrpack-deploy.log >> "!LOG_FILE!"
    if !MRPACK_ERR! neq 0 goto mrpack_failed
)
goto mrpack_check
:mrpack_failed
echo %RED%Failed: Modpack deployment failed. Check your network connection.%RESET%
echo [4] Failed: Modpack deployment failed. >> "!LOG_FILE!"
if exist mrpack-deploy.log (
    type mrpack-deploy.log >> "!LOG_FILE!"
    del mrpack-deploy.log 2>nul
)
pause & exit /b 1
:mrpack_check
findstr /i "Download failed" mrpack-deploy.log >nul
if not errorlevel 1 (
    echo %YELLOW%Warn: One or more files failed to download, server may be missing some mods or configs.%RESET%
    echo %YELLOW%Re-run the script to retry, already downloaded files will be skipped.%RESET%
    echo [4] Warn: One or more files failed to download. >> "!LOG_FILE!"
)
del mrpack-deploy.log 2>nul
echo.

:: 5. Remove client-only mods
echo %YELLOW%Removing client-only mods...%RESET%
echo [5] Removing client-only mods... >> "!LOG_FILE!"
if not exist ".modremover" (
    echo %RED%Failed: .modremover file not found.%RESET%
    echo [5] Failed: .modremover file not found. >> "!LOG_FILE!"
    pause & exit /b 1
)
for /f "usebackq delims=" %%i in (".modremover") do (
    if exist "mods\%%i" (
        del "mods\%%i"
        echo [5] Removed: %%i >> "!LOG_FILE!"
    )
)
echo.

:: 6. Remove client-only configs
echo %YELLOW%Removing client-only configs...%RESET%
echo [6] Removing client-only configs... >> "!LOG_FILE!"
if not exist ".configremover" (
    echo .configremover not found, skipping.
    echo [6] .configremover not found, skipping. >> "!LOG_FILE!"
) else (
    for /f "usebackq delims=" %%i in (".configremover") do (
        set "ITEM=%%i"
        if "!ITEM:~-1!"=="/" (
            set "FOLDER=!ITEM:~0,-1!"
            if exist "config\!FOLDER!" (
                rd /s /q "config\!FOLDER!"
                echo [6] Removed folder: !FOLDER! >> "!LOG_FILE!"
            )
        ) else (
            if exist "config\!ITEM!" (
                del "config\!ITEM!" 2>nul
                echo [6] Removed: !ITEM! >> "!LOG_FILE!"
            )
        )
    )
)
echo.

:: 7. Cleanup
:: Installer files are kept intentionally for re-deployment without re-downloading.
:: Remove the goto below to enable cleanup.
goto skip_cleanup
echo %YELLOW%Cleaning up...%RESET%
del forge-1.20.1-47.4.13-installer.jar 2>nul
del forge-1.20.1-47.4.13-installer.jar.log 2>nul
:skip_cleanup
echo.

:: 8. Remove client-only resourcepacks and shaderpacks
echo %YELLOW%Removing client-only resourcepacks and shaderpacks...%RESET%
echo [8] Removing client-only resourcepacks and shaderpacks... >> "!LOG_FILE!"
del "resourcepacks\ClickSound.zip" 2>nul
del "resourcepacks\Dark Smooth GUI.zip" 2>nul
del "resourcepacks\Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip" 2>nul
if exist "shaderpacks" rd /s /q "shaderpacks"
echo.

echo %GREEN%Done. Run run.bat to start the server.%RESET%
echo [Done] Deployment completed - %DATE% %TIME% >> "!LOG_FILE!"
pause