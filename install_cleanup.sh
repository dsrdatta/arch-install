#!/bin/bash
set -e

echo "📦 Finalizing base installation..."

# Load NEW_USERNAME from .env file
source .env

arch-chroot /mnt /bin/bash <<EOF

# Clone Phase 2 setup from GitHub into the new user's home directory
git clone https://github.com/dsrdatta/arch-install.git /home/$NEW_USERNAME/arch-install

# Set correct ownership
chown -R $NEW_USERNAME:users /home/$NEW_USERNAME/arch-install

# Make Phase 2 script executable
chmod +x /home/$NEW_USERNAME/arch-install/post_setup.sh

EOF

# Unmount all partitions
umount -R /mnt
echo "✅ Unmounted all partitions."

# Reboot in 5 seconds
echo "🔁 Rebooting into your new Arch system in 5 seconds..."
sleep 5
reboot