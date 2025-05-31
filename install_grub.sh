arch-chroot /mnt /bin/bash <<EOF

# Install GRUB and EFI tools
pacman -Sy --noconfirm grub efibootmgr dosfstools mtools

# Install GRUB to EFI system
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo "✔️ GRUB bootloader installed."