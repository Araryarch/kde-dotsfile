#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/Araryarch/kde-dotsfile.git"
TARGET_DIR="$HOME/dotsfiles"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}⬇️  Bootstrapping Ararya's Dotfiles...${NC}"

# Check for git
if ! command -v git &> /dev/null; then
    echo "⚠️  Git not found. Installing git..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y git
    else
        echo "❌ Could not install git. Please install it manually."
        exit 1
    fi
fi

# Clone or Update
if [ -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}📂 Directory $TARGET_DIR exists. Updating...${NC}"
    cd "$TARGET_DIR" && git pull
else
    echo -e "${BLUE}Mw Cloning $REPO_URL...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

# Run Install
echo -e "${GREEN}🚀 Launching install.sh...${NC}"
chmod +x "$TARGET_DIR/install.sh"
exec "$TARGET_DIR/install.sh"
