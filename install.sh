#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Add or remove entries here
configs=(
  "nvim"
  "gtk-3.0"
  "gtk-4.0"
  "alacritty"
  "sway"
  "waybar"
  "wofi"
)

for config in "${configs[@]}"; do
  src="$DOTFILES_DIR/$config"
  dest="$CONFIG_DIR/$config"

  if [ ! -d "$src" ]; then
    echo "Skipping $config (not found in repo)"
    continue
  fi

  if [ -L "$dest" ]; then
    echo "Relinking $config"
    rm "$dest"
  elif [ -d "$dest" ]; then
    echo "$dest already exists and is not a symlink, skipping"
	continue
  fi

  ln -s "$src" "$dest"
  echo "Linked $config"
done

# NixOS config is a bit different
NIXOS_SRC="$DOTFILES_DIR/nixos"
NIXOS_DEST="/etc/nixos"

if [ -d "$NIXOS_SRC" ]; then
  if [ -L "$NIXOS_DEST" ]; then
    echo "Relinking /etc/nixos"
    sudo rm "$NIXOS_DEST"
  elif [ -d "$NIXOS_DEST" ]; then
    echo "$dest already exists and is not a symlink, skipping"
	continue
  fi

  sudo ln -s "$NIXOS_SRC" "$NIXOS_DEST"
  echo "Linked nixos config"
fi

echo "Done!"
