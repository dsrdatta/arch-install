#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

echo -e "${CYAN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

echo -e "${CYAN}Installing essential packages...${NC}"
sudo pacman -S --noconfirm \
    base-devel \
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
    fzf \
    yazi \
    curl \
    zoxide \
    zsh \
    lsd \
    zsh-completions \
    nodejs \
    npm \
    go \
    gcc \
    base-devel \
    lua \
    luarocks \
    pacman-contrib \
    ncdu \
    docker

# Create and switch to a temp dir
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build yay (no root required)
makepkg -s --noconfirm

# Install the resulting package as root
sudo pacman -U --noconfirm yay-*.pkg.tar.zst

# Clone the arch-install repo if it doesn't exist
if [ ! -d ~/dotfiles ]; then
    echo -e "${CYAN}Cloning dotfiles repo...${NC}"
    git clone https://github.com/dsrdatta/hyprdotfiles ~/dotfiles
fi

# Symlink all config directories from ~/dotfiles/config/* into $HOME
echo -e "${CYAN}Stowing dotfiles into \$HOME...${NC}"
cd ~/dotfiles/configs
# Delete some unrequired dots
rm -rf hypr waybar
stow --target=$HOME */
cd
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Set Zsh as the default shell for the current user
echo -e "${CYAN}Setting Zsh as default shell...${NC}"
sudo pacman -S --noconfirm which
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
SOURCE_LINE="source ~/myzsh.zsh"
echo "$SOURCE_LINE" >>"$ZSHRC"
echo "${CYAN}Added sourcing line to $ZSHRC.${NC}"

echo -e "${CYAN}Cloud-init Post-setup complete.${NC}"
