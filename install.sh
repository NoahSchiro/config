#!/usr/bin/env bash

set -e

# Define folder mappings
declare -A LINUX_MAP=(
  [i3]="$HOME/.config/i3"
  [i3blocks]="$HOME/.config/i3blocks"
  [rofi]="$HOME/.config/rofi"
  [nvim]="$HOME/.config/nvim"
)

declare -A MAC_MAP=(
  [nvim]="$HOME/.config/nvim"
)

# Determine OS
OS=$(uname)
if [[ "$OS" == "Darwin" ]]; then
  echo "Detected macOS 🍎"
  declare -n CURRENT_MAP=MAC_MAP
elif [[ "$OS" == "Linux" ]]; then
  echo "Detected Linux 🐧"
  declare -n CURRENT_MAP=LINUX_MAP
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# Loop through the folder mappings
for folder in "${!CURRENT_MAP[@]}"; do
  src_dir="$(pwd)/$folder"
  dest_dir="${CURRENT_MAP[$folder]}"

  if [[ ! -d "$src_dir" ]]; then
    echo "🚫 Skipping '$folder' — source folder not found."
    continue
  fi

  echo "Installing '$folder' to $dest_dir"

  if [[ -e "$dest_dir" ]]; then
    read -p "⚠️ '$dest_dir' already exists. Overwrite? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      echo "Removing existing $dest_dir..."
      rm -rf "$dest_dir"
    else
      echo "Skipping $folder"
      continue
    fi
  fi

  echo "Copying $src_dir to $dest_dir"
  cp -r "$src_dir" "$dest_dir"
done

echo "✅ Configuration install completed."
