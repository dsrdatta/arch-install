#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

echo -e "${CYAN}Installing GRUB bootloader...${NC}"

arch-chroot /mnt /bin/bash <<EOF

# Install GRUB and EFI tools
pacman -Sy --noconfirm grub efibootmgr dosfstools mtools

# Install GRUB to EFI system
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo -e "${CYAN}GRUB bootloader installation complete.${NC}"
