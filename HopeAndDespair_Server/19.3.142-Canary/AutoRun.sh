#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

echo ""
echo "==================================="
echo "Modpack Server Setup Script"
echo "Made by LithumC, MIT License"
echo "Version 2.1, released on 2026-05-16"
echo "==================================="
echo ""

# 1. Download mrpack-install
echo "If the download is too slow or fails, use vpn or a different network connection."
echo "Or download mrpack-install-linux manually, need v0.16.10 or later."
if [ -f "mrpack-install-linux" ]; then
    echo "mrpack-install-linux already exists, skipping download."
else
    echo -e "${YELLOW}Downloading mrpack-install-linux...${RESET}"
    curl -L -o mrpack-install-linux "https://github.com/nothub/mrpack-install/releases/download/v0.16.10/mrpack-install-linux"
    chmod +x mrpack-install-linux
fi
echo ""

# 2. Download Forge installer
echo "If the download is too slow or fails, use vpn or a different network connection."
echo "Or download Forge-1.20.1-47.4.13.jar manually, need Forge 1.20.1-47.4.13 installer."
if [ -f "Forge-1.20.1-47.4.13.jar" ]; then
    echo "Forge-1.20.1-47.4.13.jar already exists, skipping download."
else
    echo -e "${YELLOW}Downloading Forge installer...${RESET}"
    curl -L -o Forge-1.20.1-47.4.13.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-installer.jar"
fi
echo ""

# 3. Install Forge server
echo "Run this script with Java 17 or later, and make sure java is in your PATH."
echo -e "${YELLOW}Installing Forge server...${RESET}"
java -jar Forge-1.20.1-47.4.13.jar --installServer
echo ""

# 4. Deploy modpack
echo "If the download is too slow or fails, use vpn or a different network connection."
echo -e "${YELLOW}Deploying modpack...${RESET}"
./mrpack-install-linux UeU522Qh 19.3.142-Canary --server-dir . --server-file libraries/net/minecraftforge/forge/1.20.1-47.4.13/forge-1.20.1-47.4.13-universal.jar
echo ""

# 5. Remove client-only mods
echo -e "${YELLOW}Removing client-only mods...${RESET}"
while IFS= read -r mod; do
    [ -z "$mod" ] && continue
    if [ -f "mods/$mod" ]; then
        rm "mods/$mod"
    fi
done < ".modremover"
echo ""

# 6. Cleanup
# echo -e "${YELLOW}Cleaning up...${RESET}"
# rm Forge-1.20.1-47.4.13.jar
# rm Forge-1.20.1-47.4.13.jar.log
# echo ""

# 7. Remove client-only resourcepacks and shaderpacks
echo -e "${YELLOW}Removing client-only resourcepacks and shaderpacks...${RESET}"
rm -f "resourcepacks/ClickSound.zip"
rm -f "resourcepacks/Dark Smooth GUI.zip"
rm -f "resourcepacks/Minecraft-Mod-Language-Modpack-Converted-1.20.1.zip"
rm -rf "shaderpacks"
echo ""

echo -e "${GREEN}Done. Run ./run.sh to start the server.${RESET}"