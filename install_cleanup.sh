#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

echo -e "${CYAN}Finalizing base installation...${NC}"

# Load environment variables
if [[ ! -f .env ]]; then
    echo -e "${CYAN}Error: .env file not found!${NC}"
    exit 1
fi
source .env

# Define final log destination
FINAL_LOG="/mnt/home/$NEW_USERNAME/full_install.log"

echo -e "${CYAN}Saving configuration and preinstall summary to $FINAL_LOG...${NC}"

# Combine .env and preinstall_summary.txt into one log file
{
    echo "=== .env Configuration ==="
    cat .env
    echo
    echo "=== Preinstall Summary ==="
    cat preinstall_summary.txt 2>/dev/null || echo "No preinstall_summary.txt found."
} > "$FINAL_LOG"

# Set correct ownership for the new user
chown "$NEW_USERNAME:users" "$FINAL_LOG"

# Clone post-setup script into home directory
echo -e "${CYAN}Cloning post-setup script into new user's home directory...${NC}"
arch-chroot /mnt /bin/bash <<EOF
git clone https://github.com/dsrdatta/arch-install.git /home/$NEW_USERNAME/arch-install
chown -R $NEW_USERNAME:users /home/$NEW_USERNAME/arch-install
chmod +x /home/$NEW_USERNAME/arch-install/post_setup.sh
EOF

# Unmount all partitions
echo -e "${CYAN}Unmounting all partitions...${NC}"
umount -R /mnt

echo -e "${CYAN}Rebooting into your new Arch system in 5 seconds...${NC}"
sleep 5
reboot
