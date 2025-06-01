#!/bin/bash
set -e

echo "📦 Finalizing base installation..."

# Load environment variables
if [[ ! -f .env ]]; then
    echo "Error: .env file not found!"
    exit 1
fi
source .env

# Define final log destination
FINAL_LOG="/mnt/home/$NEW_USERNAME/full_install.log"

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
arch-chroot /mnt /bin/bash <<EOF
git clone https://github.com/dsrdatta/arch-install.git /home/$NEW_USERNAME/arch-install
chown -R $NEW_USERNAME:users /home/$NEW_USERNAME/arch-install
chmod +x /home/$NEW_USERNAME/arch-install/post_setup.sh
EOF

# Unmount all partitions
umount -R /mnt
echo "✅ Unmounted all partitions."

# Reboot in 5 seconds
echo "🔁 Rebooting into your new Arch system in 5 seconds..."
sleep 5
reboot