#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

# Load environment variables
if [[ ! -f .env ]]; then
    echo -e "${CYAN}Error: .env file not found!${NC}"
    exit 1
fi

source .env

if [[ -z "$ROOT_PASSWORD" || -z "$NEW_USERNAME" || -z "$USER_PASSWORD" || -z "$hostname" ]]; then
    echo -e "${CYAN}Error: Missing required environment variables (ROOT_PASSWORD, NEW_USERNAME, USER_PASSWORD, hostname)${NC}"
    exit 1
fi

echo -e "${CYAN}Entering chroot and configuring base system...${NC}"

arch-chroot /mnt /bin/bash -e <<EOF

# Set timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname and hosts
echo "$hostname" > /etc/hostname

cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
HOSTS

# Set root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Create new user
useradd -m -G wheel,storage,power,video,audio -s /bin/bash $NEW_USERNAME
echo "$NEW_USERNAME:$USER_PASSWORD" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable NetworkManager
systemctl enable NetworkManager

EOF

echo -e "${CYAN}Chroot configuration complete: locale, user, root password, hostname, sudo setup${NC}"
