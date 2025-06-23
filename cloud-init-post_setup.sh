#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

echo -e "${CYAN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

echo -e "${CYAN}Installing essential packages...${NC}"
sudo pacman -S --noconfirm \
    kitty \
    fastfetch \
    btop \
    git \
    git \
    nano \
    neovim \
    rsync \
    stow \
    tmux \
    unzip \
    yazi \
    zoxide \
    zsh \
    zsh-completions

# Create and switch to a temp dir
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build yay (no root required)
makepkg -s --noconfirm

# Install the resulting package as root
sudo pacman -U --noconfirm yay-*.pkg.tar.zst

echo -e "${CYAN}Cloud-init Post-setup complete.${NC}"
