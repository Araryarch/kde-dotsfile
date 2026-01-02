#!/usr/bin/env bash

set -e

SRC="$HOME/.config"
DEST="$HOME/dotsfiles/config"

echo "🔄 Sync config ke dotfiles..."
echo "📂 Source : $SRC"
echo "📂 Target : $DEST"
echo

mkdir -p "$DEST/kde"

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

# ===== LOOKS CONFIG =====
sync_dir "$SRC/rofi" "$DEST/rofi"
sync_dir "$SRC/gtk-3.0" "$DEST/gtk-3.0"
sync_dir "$SRC/gtk-4.0" "$DEST/gtk-4.0"


echo
echo "🎉 Done! Dotfiles updated."

