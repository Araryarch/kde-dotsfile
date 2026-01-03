#!/usr/bin/env bash

set -e

SRC="$HOME/.config"
DEST="$HOME/dotsfiles/config"

SRC_SHARE="$HOME/.local/share"
DEST_SHARE="$HOME/dotsfiles/local/share"

echo "🔄 Sync config ke dotfiles..."
echo "📂 Source Config : $SRC"
echo "📂 Source Share  : $SRC_SHARE"
echo "📂 Target        : $DEST"
echo

mkdir -p "$DEST/kde"
mkdir -p "$DEST_SHARE"

sync_dir() {
  if [ -d "$1" ]; then
    rsync -av --delete "$1/" "$2/"
    echo "✅ synced: $(basename "$1")"
  fi
}

sync_file() {
  if [ -f "$1" ]; then
    cp "$1" "$2/"
    echo "✅ copied: $(basename "$1")"
  fi
}

# ===== DEV CONFIG =====
sync_dir "$SRC/nvim" "$DEST/nvim"
sync_dir "$SRC/fish" "$DEST/fish"
sync_dir "$SRC/kitty" "$DEST/kitty"

sync_file "$SRC/starship.toml" "$DEST"

# ===== KDE CONFIG =====
sync_file "$SRC/kdeglobals" "$DEST/kde"
sync_file "$SRC/kwinrc" "$DEST/kde"
sync_file "$SRC/kglobalshortcutsrc" "$DEST/kde"
sync_file "$SRC/plasmarc" "$DEST/kde"
sync_file "$SRC/plasmashellrc" "$DEST/kde"
sync_file "$SRC/plasma-org.kde.plasma.desktop-appletsrc" "$DEST/kde"
sync_file "$SRC/dolphinrc" "$DEST/kde"
sync_file "$SRC/konsolerc" "$DEST/kde"
sync_file "$SRC/spectaclerc" "$DEST/kde"
sync_file "$SRC/sddmthemeinstallerrc" "$DEST/kde"
sync_file "$SRC/kscreenlockerrc" "$DEST/kde"
sync_file "$SRC/kcminputrc" "$DEST/kde"
sync_file "$SRC/ksplashrc" "$DEST/kde"
sync_file "$SRC/krunnerrc" "$DEST/kde"
sync_file "$SRC/khotkeysrc" "$DEST/kde"
sync_file "$SRC/powermanagementprofilesrc" "$DEST/kde"
sync_file "$SRC/kded5rc" "$DEST/kde"

# ===== LOOKS CONFIG =====
sync_dir "$SRC/rofi" "$DEST/rofi"
sync_dir "$SRC/gtk-3.0" "$DEST/gtk-3.0"
sync_dir "$SRC/gtk-4.0" "$DEST/gtk-4.0"
sync_dir "$SRC/gtk-2.0" "$DEST/gtk-2.0"
sync_dir "$SRC/Kvantum" "$DEST/Kvantum"
sync_dir "$SRC/qt5ct" "$DEST/qt5ct"
sync_dir "$SRC/qt6ct" "$DEST/qt6ct"
sync_dir "$SRC/fontconfig" "$DEST/fontconfig"
sync_dir "$SRC/fastfetch" "$DEST/fastfetch"



# ===== UI ASSETS (Local Share) =====
# Plasma themes, widgets, etc.
if [ -d "$SRC_SHARE/plasma" ]; then
    mkdir -p "$DEST_SHARE/plasma"
    sync_dir "$SRC_SHARE/plasma/desktoptheme" "$DEST_SHARE/plasma/desktoptheme"
    sync_dir "$SRC_SHARE/plasma/look-and-feel" "$DEST_SHARE/plasma/look-and-feel"
    sync_dir "$SRC_SHARE/plasma/plasmoids" "$DEST_SHARE/plasma/plasmoids"
fi

# KWin Scripts & Effects (often where tiling scripts live)
sync_dir "$SRC_SHARE/kwin" "$DEST_SHARE/kwin"

sync_dir "$SRC_SHARE/color-schemes" "$DEST_SHARE/color-schemes"
sync_dir "$SRC_SHARE/aurorae" "$DEST_SHARE/aurorae"
sync_dir "$SRC_SHARE/icons" "$DEST_SHARE/icons"
sync_dir "$SRC_SHARE/fonts" "$DEST_SHARE/fonts"



# ===== WALLPAPERS =====
mkdir -p "$DEST/wallpapers"
if [ -f "$HOME/Pictures/hutao.png" ]; then
    cp "$HOME/Pictures/hutao.png" "$DEST/wallpapers/"
    echo "✅ copied: hutao.png"
fi

# ===== PACKAGES LIST =====
# Generate a list of explicitly installed packages
if command -v pacman &> /dev/null; then
    pacman -Qqe > "$DEST/pkglist.txt"
    echo "✅ generated: pkglist.txt (Arch packages)"
fi

echo
echo "🎉 Done! Dotfiles updated."

