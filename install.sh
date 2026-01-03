#!/usr/bin/env bash

set -e

# ================= VARIABLES =================
DOTS="$HOME/dotsfiles/config"
TARGET="$HOME/.config"
BACKUP="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$HOME/dotfiles_install.log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Dependencies to install
PACKAGES=(
  # KDE & Core
  "plasma-meta"
  "konsole"
  "dolphin"
  "ark"
  "spectacle"
  "sddm"
  
  # Tools & shell
  "neovim"
  "fish"
  "kitty"
  "starship"
  "rofi"
  "fastfetch"
  "ttf-font-awesome" # Common font for icons
)

# ================= UTILS =================

info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
  echo -e "${GREEN}✅ $1${NC}"
}

warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
  echo -e "${RED}❌ $1${NC}"
}

spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p "$pid" > /dev/null 2>&1; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# ================= TASKS =================

check_deps() {
  info "Checking package manager..."
  if command -v yay &> /dev/null; then
    PKG_MGR="yay -S --needed --noconfirm"
    success "Using yay"
  elif command -v pacman &> /dev/null; then
    PKG_MGR="sudo pacman -S --needed --noconfirm"
    success "Using pacman"
  else
    warn "No Arch package manager found. Skipping dependency installation."
    return
  fi

  info "Installing dependencies..."
  echo "Packages: ${PACKAGES[*]}"
  
  # Run installation in background to show spinner
  $PKG_MGR "${PACKAGES[@]}" > "$LOG_FILE" 2>&1 &
  spinner $!
  
  if [ $? -eq 0 ]; then
    success "Dependencies installed!"
  else
    error "Dependency installation failed. Check $LOG_FILE"
  fi

  if [ -f "$DOTS/pkglist.txt" ]; then
      info "Found pkglist.txt. You can install all original packages with:"
      echo -e "${Cyan}   $PKG_MGR - < \"$DOTS/pkglist.txt\"${NC}"
  fi
}

backup_configs() {
  info "Backing up existing configs..."
  echo "Target: $BACKUP"
  mkdir -p "$BACKUP"

  (
    if [ -d "$TARGET" ]; then
      cp -a "$TARGET/." "$BACKUP/"
    fi
  ) &
  spinner $!
  
  success "Backup complete!"
}

install_dir() {
  local name=$1
  if [ -d "$DOTS/$name" ]; then
    rm -rf "$TARGET/$name"
    cp -a "$DOTS/$name" "$TARGET/"
    echo -e "   ${CYAN}→ Installed dir : $name${NC}"
  fi
}

install_file() {
  local name=$1
  if [ -f "$DOTS/$name" ]; then
    # Create parent dir if needed (e.g. for kde files)
    mkdir -p "$(dirname "$TARGET/$name")"
    cp -a "$DOTS/$name" "$TARGET/"
    echo -e "   ${CYAN}→ Installed file: $name${NC}"
  fi
}

install_configs() {
  info "Installing dotfiles..."
  
  # DEV
  install_dir "nvim"
  install_dir "fish"
  install_dir "kitty"
  install_file "starship.toml"

  # KDE
  install_file "kde/kdeglobals"
  install_file "kde/kwinrc"
  install_file "kde/kglobalshortcutsrc"
  install_file "kde/plasmarc"
  install_file "kde/plasmashellrc"
  install_file "kde/plasma-org.kde.plasma.desktop-appletsrc"
  install_file "kde/dolphinrc"
  install_file "kde/konsolerc"
  install_file "kde/spectaclerc"
  install_file "kde/sddmthemeinstallerrc"

  # LOOKS
  install_dir "rofi"
  install_dir "fastfetch"
  install_dir "gtk-3.0"
  install_dir "gtk-3.0"
  install_dir "gtk-4.0"
  install_dir "gtk-2.0"
  install_dir "Kvantum"
  install_dir "qt5ct"
  install_dir "qt6ct"
  install_dir "fontconfig"
  
  # SYSTEM
  install_dir "autostart"
  install_file "kde/mimeapps.list"

  # DATA (Share)
  # Konsole profiles are often in share/konsole, not just config
  if [ -d "$DOTS/local/share/konsole" ]; then
    mkdir -p "$HOME/.local/share"
    cp -r "$DOTS/local/share/konsole" "$HOME/.local/share/"
    echo -e "   ${CYAN}→ Installed data: konsole profiles${NC}"
  fi
  if [ -f "$DOTS/local/share/user-places.xbel" ]; then
    cp "$DOTS/local/share/user-places.xbel" "$HOME/.local/share/"
    echo -e "   ${CYAN}→ Installed file: user-places.xbel${NC}"
  fi

  # WALLPAPERS
  if [ -f "$DOTS/wallpapers/hutao.png" ]; then
    mkdir -p "$HOME/Pictures"
    cp "$DOTS/wallpapers/hutao.png" "$HOME/Pictures/"
    echo -e "   ${CYAN}→ Installed wallpaper: hutao.png${NC}"

    # Try setting wallpaper via qdbus if in a plasma session
    if command -v qdbus &> /dev/null && pgrep plasmashell > /dev/null; then
        echo -e "   ${BLUE}→ Configuring KDE wallpaper...${NC}"
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
            var allDesktops = desktops();
            for (i=0;i<allDesktops.length;i++) {
                d = allDesktops[i];
                d.wallpaperPlugin = "org.kde.image";
                d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
                d.writeConfig("Image", "file://'"$HOME"'/Pictures/hutao.png");
            }'
    fi
  fi

  success "Configs installed!"
}

# ================= MAIN =================

clear
echo -e "${CYAN}🚀 Ararya's Dotfiles Installer${NC}"
echo "=============================="
echo

check_deps
echo
backup_configs
echo
install_configs

echo
echo -e "${GREEN}🎉 All done! Please restart your shell/session.${NC}"
echo -e "${YELLOW}Note: KDE changes might require a specialized restart or logout.${NC}"
echo


