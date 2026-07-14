#!/bin/bash

GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;96m'
RED='\033[0;91m'
RESET='\033[0m'

echo ""
echo -e "${BLUE}+-------------------------------+${RESET}"
echo -e "${BLUE}|  Hope and Despair             |${RESET}"
echo -e "${BLUE}|  Server Setup Script v3.6     |${RESET}"
echo -e "${BLUE}|  Made by LithumC             |${RESET}"
echo -e "${BLUE}|  MIT License                  |${RESET}"
echo -e "${BLUE}+-------------------------------+${RESET}"
echo ""
echo -e "Current modpack version: ${YELLOW}HAD 19.4.159${RESET}"
echo ""
while true; do
    read -p "Proceed with installation? [Y/N]: " CONFIRM
    case "$CONFIRM" in
        [Yy]) break ;;
        [Nn])
            echo "Installation cancelled."
            exit 0
            ;;
        *) echo "Invalid input, please enter Y or N." ;;
    esac
done
echo ""

LOG_FILE="autorun.log"
echo "AutoRun.sh v3.6 - $(date)" > "$LOG_FILE"
echo "Modpack: Hope and despair 19.4.159" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 0. Check Java version and JDK/JRE
echo -e "${YELLOW}Checking Java version...${RESET}"
if ! command -v java &>/dev/null; then
    echo -e "${RED}Failed: Java not found. Please install Java 17 or later.${RESET}"
    echo "[0] Failed: Java not found." >> "$LOG_FILE"
    exit 1
fi
JAVA_VER_RAW=$(java -version 2>&1 | grep -i "version" | awk -F'"' '{print $2}')
JAVA_MAJOR=$(echo "$JAVA_VER_RAW" | cut -d'.' -f1)
if [ "$JAVA_MAJOR" -lt 17 ]; then
    echo -e "${RED}Failed: Java $JAVA_VER_RAW detected, Java 17 or later is required.${RESET}"
    echo "[0] Failed: Java $JAVA_VER_RAW detected, Java 17+ required." >> "$LOG_FILE"
    exit 1
fi
echo "Java $JAVA_VER_RAW detected, OK."
echo "[0] Java $JAVA_VER_RAW detected, OK." >> "$LOG_FILE"
if ! command -v javac &>/dev/null; then
    echo -e "${YELLOW}Warn: JDK not detected, you may be using JRE. High version JRE may cause compatibility issues, JDK is recommended.${RESET}"
    echo "[0] Warn: JDK not detected, possibly using JRE." >> "$LOG_FILE"
fi
echo ""

# 1. Download mrpack-install
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Or download mrpack-install-linux manually, need v0.16.10 or later.${RESET}"
if [ -f "mrpack-install-linux" ]; then
    echo "mrpack-install-linux already exists, skipping download."
    echo "[1] mrpack-install-linux already exists, skipping download." >> "$LOG_FILE"
else
    echo -e "${YELLOW}Downloading mrpack-install-linux...${RESET}"
    echo "[1] Downloading mrpack-install-linux..." >> "$LOG_FILE"
    curl -fL -o mrpack-install-linux "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-linux"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed: Could not download mrpack-install-linux.${RESET}"
        echo "[1] Failed: Could not download mrpack-install-linux." >> "$LOG_FILE"
        exit 1
    fi
    chmod +x mrpack-install-linux
    echo "[1] mrpack-install-linux downloaded successfully." >> "$LOG_FILE"
fi
echo ""

# 2. Download Forge installer
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Or download forge-1.20.1-47.4.13-installer.jar manually, need Forge 1.20.1-47.4.13 installer.${RESET}"
if [ -f "forge-1.20.1-47.4.13-installer.jar" ]; then
    echo "forge-1.20.1-47.4.13-installer.jar already exists, skipping download."
    echo "[2] forge-1.20.1-47.4.13-installer.jar already exists, skipping download." >> "$LOG_FILE"
else
    echo -e "${YELLOW}Downloading Forge installer...${RESET}"
    echo "[2] Downloading Forge installer..." >> "$LOG_FILE"
    curl -fL -o forge-1.20.1-47.4.13-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed: Could not download Forge installer.${RESET}"
        echo "[2] Failed: Could not download Forge installer." >> "$LOG_FILE"
        exit 1
    fi
    echo "[2] Forge installer downloaded successfully." >> "$LOG_FILE"
fi
echo ""

# 3. Install Forge server
echo -e "${YELLOW}Run this script with Java 17 or later, and make sure java is in your PATH.${RESET}"
echo -e "${YELLOW}Installing Forge server, this may take a few minutes...${RESET}"
echo -e "${YELLOW}Full output is being written to autorun.log${RESET}"
echo "[3] Installing Forge server..." >> "$LOG_FILE"
java -jar forge-1.20.1-47.4.13-installer.jar --installServer >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed: Forge installation failed. Make sure Java 17+ is installed and in PATH.${RESET}"
    echo "[3] Failed: Forge installation failed." >> "$LOG_FILE"
    exit 1
fi
echo "[3] Forge installed successfully." >> "$LOG_FILE"
echo ""

# 4. Deploy modpack
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Deploying modpack...${RESET}"
echo "[4] Deploying modpack..." >> "$LOG_FILE"
if [ -f "Hope and despair 19.4.159.mrpack" ]; then
    echo "Modpack file already exists, deploying from local file."
    echo -e "${YELLOW}Warn: If this script is not running as root and the server directory requires elevated permissions, you may be prompted for your sudo password.${RESET}"
    echo "[4] Deploying from local file." >> "$LOG_FILE"
    ./mrpack-install-linux "Hope and despair 19.4.159.mrpack" --server-dir . --server-file libraries/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    MRPACK_ERR=$?
    cat mrpack-deploy.log
    cat mrpack-deploy.log >> "$LOG_FILE"
    if [ $MRPACK_ERR -ne 0 ]; then
        echo -e "${RED}Failed: Modpack deployment failed. Check your network connection.${RESET}"
        echo "[4] Failed: Modpack deployment failed." >> "$LOG_FILE"
        rm -f mrpack-deploy.log
        exit 1
    fi
else
    ./mrpack-install-linux UeU522Qh 19.4.159 --server-dir . --server-file libraries/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    MRPACK_ERR=$?
    cat mrpack-deploy.log
    cat mrpack-deploy.log >> "$LOG_FILE"
    if [ $MRPACK_ERR -ne 0 ]; then
        echo -e "${RED}Failed: Modpack deployment failed. Check your network connection.${RESET}"
        echo "[4] Failed: Modpack deployment failed." >> "$LOG_FILE"
        rm -f mrpack-deploy.log
        exit 1
    fi
fi
if grep -qi "Download failed" mrpack-deploy.log; then
    echo -e "${YELLOW}Warn: One or more files failed to download, server may be missing some mods or configs.${RESET}"
    echo -e "${YELLOW}Re-run the script to retry, already downloaded files will be skipped.${RESET}"
    echo "[4] Warn: One or more files failed to download." >> "$LOG_FILE"
fi
rm -f mrpack-deploy.log
echo ""

# 5. Remove client-only mods
echo -e "${YELLOW}Removing client-only mods...${RESET}"
echo "[5] Removing client-only mods..." >> "$LOG_FILE"
if [ ! -f ".modremover" ]; then
    echo -e "${RED}Failed: .modremover file not found.${RESET}"
    echo "[5] Failed: .modremover file not found." >> "$LOG_FILE"
    exit 1
fi
while IFS= read -r mod; do
    [ -z "$mod" ] && continue
    if [ -f "mods/$mod" ]; then
        rm "mods/$mod"
        echo "[5] Removed: $mod" >> "$LOG_FILE"
    fi
done < ".modremover"
echo ""

# 6. Remove client-only configs
echo -e "${YELLOW}Removing client-only configs...${RESET}"
echo "[6] Removing client-only configs..." >> "$LOG_FILE"
if [ ! -f ".configremover" ]; then
    echo ".configremover not found, skipping."
    echo "[6] .configremover not found, skipping." >> "$LOG_FILE"
else
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        if [[ "$item" == */ ]]; then
            folder="${item%/}"
            if [ -d "config/$folder" ]; then
                rm -rf "config/$folder"
                echo "[6] Removed folder: $folder" >> "$LOG_FILE"
            fi
        else
            if [ -f "config/$item" ]; then
                rm -f "config/$item"
                echo "[6] Removed: $item" >> "$LOG_FILE"
            fi
        fi
    done < ".configremover"
fi
echo ""

# 7. Cleanup
# Installer files are kept intentionally for re-deployment without re-downloading.
# Uncomment the lines below to enable cleanup.
# echo -e "${YELLOW}Cleaning up...${RESET}"
# rm -f forge-1.20.1-47.4.13-installer.jar
# rm -f forge-1.20.1-47.4.13-installer.jar.log
# echo ""

# 8. Remove client-only resourcepacks and shaderpacks
echo -e "${YELLOW}Removing client-only resourcepacks and shaderpacks...${RESET}"
echo "[8] Removing client-only resourcepacks and shaderpacks..." >> "$LOG_FILE"
rm -f "resourcepacks/ClickSound.zip"
rm -f "resourcepacks/Dark Smooth GUI.zip"
rm -f "resourcepacks/Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip"
rm -rf "shaderpacks"
echo ""

echo -e "${GREEN}Done. Run ./run.sh to start the server.${RESET}"
echo "[Done] Deployment completed - $(date)" >> "$LOG_FILE"
