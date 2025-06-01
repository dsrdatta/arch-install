#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

# Load NEW_USERNAME from .env
source ~/arch-install/.env

# Ensure script is run by correct user
if [ "$(whoami)" != "$NEW_USERNAME" ]; then
    echo -e "${CYAN}Please run this script as the user: $NEW_USERNAME${NC}"
    exit 1
fi

echo -e "${CYAN}Updating system and installing packages...${NC}"

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm \
    kitty \
    dolphin \
    fastfetch \
    btop \
    git \
    nano
    # Uncomment below if needed
    # network-manager-applet \
    # base-devel

# Install yay if not already installed
if ! command -v yay &>/dev/null; then
    echo -e "${CYAN}Installing yay (AUR helper)...${NC}"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

# Install AUR packages with yay
yay -S --noconfirm brave-bin

echo -e "${CYAN}Post-setup complete.${NC}"