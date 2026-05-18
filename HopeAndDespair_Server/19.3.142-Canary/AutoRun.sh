#!/bin/bash

GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;96m'
RED='\033[0;91m'
RESET='\033[0m'

echo ""
echo -e "${BLUE}======================================${RESET}"
echo -e "${BLUE}  Modpack Server Setup Script${RESET}"
echo -e "${BLUE}  Made by LithumC | MIT License${RESET}"
echo -e "${BLUE}  Version 2.11 | 2026-05-17${RESET}"
echo -e "${BLUE}  Supported: HAD 19.3.142-Canary${RESET}"
echo -e "${BLUE}======================================${RESET}"
echo ""
echo "Current modpack version: HAD 19.3.142-Canary"
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

# 1. Download mrpack-install
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Or download mrpack-install-linux manually, need v0.16.10 or later.${RESET}"
if [ -f "mrpack-install-linux" ]; then
    echo "mrpack-install-linux already exists, skipping download."
else
    echo -e "${YELLOW}Downloading mrpack-install-linux...${RESET}"
    curl -fL -o mrpack-install-linux "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-linux"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed: Could not download mrpack-install-linux.${RESET}"
        exit 1
    fi
    chmod +x mrpack-install-linux
fi
echo ""

# 2. Download Forge installer
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Or download forge-1.20.1-47.4.13-installer.jar manually, need Forge 1.20.1-47.4.13 installer.${RESET}"
if [ -f "forge-1.20.1-47.4.13-installer.jar" ]; then
    echo "forge-1.20.1-47.4.13-installer.jar already exists, skipping download."
else
    echo -e "${YELLOW}Downloading Forge installer...${RESET}"
    curl -fL -o forge-1.20.1-47.4.13-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed: Could not download Forge installer.${RESET}"
        exit 1
    fi
fi
echo ""

# 3. Install Forge server
echo -e "${YELLOW}Run this script with Java 17 or later, and make sure java is in your PATH.${RESET}"
echo -e "${YELLOW}Installing Forge server...${RESET}"
java -jar forge-1.20.1-47.4.13-installer.jar --installServer
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed: Forge installation failed. Make sure Java 17+ is installed and in PATH.${RESET}"
    exit 1
fi
echo ""

# 4. Deploy modpack
echo -e "${YELLOW}If the download is too slow or fails, use vpn or a different network connection.${RESET}"
echo -e "${YELLOW}Deploying modpack...${RESET}"
if [ -f "Hope and despair 19.3.142-Canary.mrpack" ]; then
    echo "Modpack file already exists, deploying from local file."
    ./mrpack-install-linux "Hope and despair 19.3.142-Canary.mrpack" --server-dir . --server-file libraries/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    cat mrpack-deploy.log
else
    ./mrpack-install-linux UeU522Qh 19.3.142-Canary --server-dir . --server-file libraries/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-universal.jar > mrpack-deploy.log 2>&1
    cat mrpack-deploy.log
    if [ ! -f "Hope and despair 19.3.142-Canary.mrpack" ]; then
        echo -e "${RED}Failed: Modpack file download failed. Check your network connection.${RESET}"
        rm -f mrpack-deploy.log
        exit 1
    fi
fi
if grep -qi "Download failed" mrpack-deploy.log; then
    echo -e "${YELLOW}Warn: One or more files failed to download, server may be missing some mods or configs.${RESET}"
    echo -e "${YELLOW}Re-run the script to retry, already downloaded files will be skipped.${RESET}"
fi
rm -f mrpack-deploy.log
echo ""

# 5. Remove client-only mods
echo -e "${YELLOW}Removing client-only mods...${RESET}"
if [ ! -f ".modremover" ]; then
    echo -e "${RED}Failed: .modremover file not found.${RESET}"
    exit 1
fi
while IFS= read -r mod; do
    [ -z "$mod" ] && continue
    if [ -f "mods/$mod" ]; then
        rm "mods/$mod"
    fi
done < ".modremover"
echo ""

# 6. Cleanup
# echo -e "${YELLOW}Cleaning up...${RESET}"
# rm -f forge-1.20.1-47.4.13-installer.jar
# rm -f forge-1.20.1-47.4.13-installer.jar.log
# echo ""

# 7. Remove client-only resourcepacks and shaderpacks
echo -e "${YELLOW}Removing client-only resourcepacks and shaderpacks...${RESET}"
rm -f "resourcepacks/ClickSound.zip"
rm -f "resourcepacks/Dark Smooth GUI.zip"
rm -f "resourcepacks/Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip"
rm -rf "shaderpacks"
echo ""

echo -e "${GREEN}Done. Run ./run.sh to start the server.${RESET}"