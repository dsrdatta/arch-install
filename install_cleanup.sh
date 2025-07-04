#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

echo "${CYAN}Finalizing base installation...${NC}"

# Load environment variables
if [[ ! -f .env ]]; then
    echo "Error: .env file not found!"
    exit 1
fi
source .env

FINAL_LOG="/mnt/home/$NEW_USERNAME/full_install.log"

# Collect initial configuration details
{
    echo "=== .env Configuration ==="
    cat .env
    echo

    echo "=== Preinstall Summary ==="
    cat preinstall_summary.txt 2>/dev/null || echo "No preinstall_summary.txt found."
    echo
} > "$FINAL_LOG"

# Collect fstab and GRUB config
if [[ -f /mnt/etc/fstab ]]; then
    echo "=== /etc/fstab ===" >> "$FINAL_LOG"
    cat /mnt/etc/fstab >> "$FINAL_LOG"
    echo >> "$FINAL_LOG"
fi

if [[ -f /mnt/boot/grub/grub.cfg ]]; then
    echo "=== /boot/grub/grub.cfg ===" >> "$FINAL_LOG"
    grep -E '^menuentry|^set' /mnt/boot/grub/grub.cfg >> "$FINAL_LOG"
    echo >> "$FINAL_LOG"
fi

# root into arch for settings permissions
arch-chroot /mnt /bin/bash <<EOF

# Set permissions on final log
chown $NEW_USERNAME:users $FINAL_LOG

# Clone post-setup into user home
git clone https://github.com/dsrdatta/arch-install.git /home/$NEW_USERNAME/arch-install
chown -R $NEW_USERNAME:users /home/$NEW_USERNAME/arch-install
chmod +x /home/$NEW_USERNAME/arch-install/post_setup.sh
EOF

# Clean mount points and sync disk
echo "Cleaning up..."
sync
umount -lR /mnt

echo "System ready. Rebooting in 5 seconds..."
#sleep 5
#reboot
