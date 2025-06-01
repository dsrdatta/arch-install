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

echo -e "${CYAN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

echo -e "${CYAN}Installing essential packages...${NC}"
sudo pacman -S --noconfirm \
    base-devel \
    kitty \
    dolphin \
    fastfetch \
    btop \
    git \
    nano

# Create and switch to a temp dir
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build yay (no root required)
makepkg -s --noconfirm

# Install the resulting package as root
sudo pacman -U --noconfirm yay-*.pkg.tar.zst

# Install AUR packages
yay -S --noconfirm brave-bin

echo -e "${CYAN}Post-setup complete.${NC}"
