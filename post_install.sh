#!/bin/bash
set -e

# Load NEW_USERNAME from .env
source ~/arch-install/.env

# Ensure script is run by correct user
if [ "$(whoami)" != "$NEW_USERNAME" ]; then
    echo "Please run this script as the user: $NEW_USERNAME"
    exit 1
fi

echo "Updating system and installing packages..."

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm \
    kitty \
    dolphin \
    fastfetch \
    btop \
    fastfetch \
    git \
    nano 
    #network-manager-applet \
    #base-devel

# Install yay if not already installed
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

# Optional: install AUR packages via yay
yay -S --noconfirm brave-bin

echo "Post-setup complete."
