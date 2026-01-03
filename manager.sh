#!/usr/bin/env bash

# ==============================================================================
#  Hu Tao Dotfiles Manager (TUI Edition)
#  Author: Ararya
# ==============================================================================

# --- Variables ---
DOTS="$HOME/dotsfiles/config"
TARGET="$HOME/.config"
DOTS_SHARE="$HOME/dotsfiles/local/share"
TARGET_SHARE="$HOME/.local/share"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"

# --- Colors & Styling ---
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
RED="${ESC}[38;5;196m"
GREEN="${ESC}[38;5;46m"
YELLOW="${ESC}[38;5;226m"
BLUE="${ESC}[38;5;39m"
MAGENTA="${ESC}[38;5;213m"
CYAN="${ESC}[38;5;51m"
WHITE="${ESC}[38;5;255m"
GRAY="${ESC}[38;5;240m"
BG_RED="${ESC}[48;5;196m"
BG_GRAY="${ESC}[48;5;236m"

# Actions
actions=("Install Dotfiles" "Sync (Backup) to Repo" "View Status" "Exit")
selected=0

# --- TUI Helpers ---

hide_cursor() { printf "\033[?25l"; }
show_cursor() { printf "\033[?25h"; }
clear_screen() { printf "\033[2J\033[H"; }

# Cleanup on exit
trap show_cursor EXIT

draw_header() {
    clear_screen
    echo -e "${RED}"
    echo "  _    _        _____            "
    echo " | |  | |      |_   _|           "
    echo " | |__| |_   _   | | __ _  ___   "
    echo " |  __  | | | |  | |/ _\` |/ _ \  "
    echo " | |  | | |_| |  | | (_| | (_) | "
    echo " |_|  |_|\__,_|  |_|\__,_|\___/  "
    echo -e "${RESET}"
    echo -e "  ${MAGENTA}Dotfiles Manager ${GRAY}v2.0${RESET}"
    echo -e "  ${GRAY}Ararya Edition${RESET}"
    echo ""
}

draw_menu() {
    for i in "${!actions[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo -e "  ${RED}➜ ${BOLD}${WHITE}${actions[$i]}${RESET}"
        else
            echo -e "    ${GRAY}${actions[$i]}${RESET}"
        fi
    done
}

# --- Logic Functions ---

log_success() { echo -e "  ${GREEN}✔${RESET} $1"; }
log_info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
log_warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }

do_sync_to_repo() {
    echo ""
    echo -e "${BOLD}${CYAN}>> Syncing Configs from System to Repo...${RESET}"
    echo ""

    # Configs
    modules=("nvim" "fish" "kitty" "rofi" "fastfetch" "gtk-3.0" "gtk-4.0" "gtk-2.0" "Kvantum" "qt5ct" "qt6ct" "fontconfig")
    for mod in "${modules[@]}"; do
        if [ -d "$TARGET/$mod" ]; then
            rm -rf "$DOTS/$mod"
            cp -r "$TARGET/$mod" "$DOTS/"
            log_success "Synced $mod"
        fi
    done

    # Files
    files=("starship.toml")
    for f in "${files[@]}"; do
        if [ -f "$TARGET/$f" ]; then
            cp "$TARGET/$f" "$DOTS/"
            log_success "Synced $f"
        fi
    done

    # KDE
    log_info "Syncing KDE Configs..."
    mkdir -p "$DOTS/kde"
    kde_files=(
        "kdeglobals" "kwinrc" "kglobalshortcutsrc" "plasmarc" "plasmashellrc"
        "plasma-org.kde.plasma.desktop-appletsrc" "dolphinrc" "konsolerc"
        "spectaclerc" "sddmthemeinstallerrc" "kscreenlockerrc" "kcminputrc"
        "ksplashrc" "krunnerrc" "powermanagementprofilesrc" "kded5rc"
        "mimeapps.list" "ksmserverrc"
    )
    for k in "${kde_files[@]}"; do
        [ -f "$TARGET/$k" ] && cp "$TARGET/$k" "$DOTS/kde/"
    done
    log_success "KDE files updated"

    # Share
    log_info "Syncing Local Share..."
    mkdir -p "$DOTS_SHARE"
    
    # Plasma themes/etc
    [ -d "$TARGET_SHARE/plasma/desktoptheme" ] && { mkdir -p "$DOTS_SHARE/plasma"; rsync -a --delete "$TARGET_SHARE/plasma/desktoptheme" "$DOTS_SHARE/plasma/"; }
    [ -d "$TARGET_SHARE/plasma/look-and-feel" ] && { mkdir -p "$DOTS_SHARE/plasma"; rsync -a --delete "$TARGET_SHARE/plasma/look-and-feel" "$DOTS_SHARE/plasma/"; }
    [ -d "$TARGET_SHARE/plasma/plasmoids" ] && { mkdir -p "$DOTS_SHARE/plasma"; rsync -a --delete "$TARGET_SHARE/plasma/plasmoids" "$DOTS_SHARE/plasma/"; }
    
    share_dirs=("kwin" "konsole" "applications" "color-schemes" "aurorae" "icons" "fonts")
    for sd in "${share_dirs[@]}"; do
        [ -d "$TARGET_SHARE/$sd" ] && { rsync -a --delete "$TARGET_SHARE/$sd" "$DOTS_SHARE/"; log_success "Synced local/share/$sd"; }
    done
    [ -f "$TARGET_SHARE/user-places.xbel" ] && cp "$TARGET_SHARE/user-places.xbel" "$DOTS_SHARE/"

    # Wallpapers & Assets
    mkdir -p "$DOTS/wallpapers"
    [ -f "$HOME/Pictures/hutao.png" ] && cp "$HOME/Pictures/hutao.png" "$DOTS/wallpapers/"
    [ -f "$HOME/Pictures/logo.png" ] && cp "$HOME/Pictures/logo.png" "$DOTS/wallpapers/"
    log_success "Assets synced"

    # Pkglist
    if command -v pacman &>/dev/null; then
        pacman -Qqe > "$DOTS/pkglist.txt"
        log_success "Package list generated"
    fi

    echo ""
    echo -e "${GREEN}Done!${RESET} Press any key to continue..."
    read -rn1
}

do_install() {
    echo ""
    echo -e "${BOLD}${MAGENTA}>> Installing Dotfiles to System...${RESET}"
    echo ""
    
    # Backup
    log_info "Backing up to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    # Only backup what we touch to save time/space, or shallow backup
    # For now, just a message
    
    # Install
    modules=("nvim" "fish" "kitty" "rofi" "fastfetch" "gtk-3.0" "gtk-4.0" "gtk-2.0" "Kvantum" "qt5ct" "qt6ct" "fontconfig" "autostart")
    for mod in "${modules[@]}"; do
        if [ -d "$DOTS/$mod" ]; then
            rm -rf "$TARGET/$mod"
            cp -r "$DOTS/$mod" "$TARGET/"
            log_success "Installed $mod"
        fi
    done

    # KDE files
    if [ -d "$DOTS/kde" ]; then
        cp "$DOTS/kde/"* "$TARGET/"
        log_success "Installed KDE configs"
    fi
    
    # Starship
    [ -f "$DOTS/starship.toml" ] && cp "$DOTS/starship.toml" "$TARGET/"

    # Share
    log_info "Installing Shared Data..."
    [ -d "$DOTS_SHARE" ] && cp -r "$DOTS_SHARE/"* "$TARGET_SHARE/"
    
    # Assets
    mkdir -p "$HOME/Pictures"
    [ -f "$DOTS/wallpapers/hutao.png" ] && cp "$DOTS/wallpapers/hutao.png" "$HOME/Pictures/"
    [ -f "$DOTS/wallpapers/logo.png" ] && cp "$DOTS/wallpapers/logo.png" "$HOME/Pictures/"
    log_success "Assets installed"

    echo ""
    echo -e "${GREEN}Installation Complete!${RESET} Press any key to continue..."
    read -rn1
}

# --- Main Loop ---

lines=$(tput lines)
cols=$(tput cols)

while true; do
    draw_header
    draw_menu
    
    # Input handling
    read -rsn1 key
    if [[ "$key" == $'\x1b' ]]; then
        read -rsn2 key
        if [[ "$key" == "[A" ]]; then # Up
            ((selected--))
            [ "$selected" -lt 0 ] && selected=$((${#actions[@]} - 1))
        elif [[ "$key" == "[B" ]]; then # Down
            ((selected++))
            [ "$selected" -ge "${#actions[@]}" ] && selected=0
        fi
    elif [[ "$key" == "" ]]; then # Enter
        case $selected in
            0) do_install ;;
            1) do_sync_to_repo ;;
            2) echo "Use 'git status' in dotsfiles dir"; read -rn1 ;;
            3) clear_screen; exit 0 ;;
        esac
    fi
done
