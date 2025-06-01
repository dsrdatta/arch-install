#!/bin/bash
set -e

# Load environment variables
source .env
selected_drive="$SELECTED_DRIVE"

# Format partitions
efi_partition="${selected_drive}1"
swap_partition="${selected_drive}2"
root_partition="${selected_drive}3"

echo "Formatting partitions..."
mkfs.fat -F32 "$efi_partition"
mkswap "$swap_partition"
swapon "$swap_partition"
mkfs.ext4 "$root_partition"

# Mount root and EFI
mount "$root_partition" /mnt
mkdir -p /mnt/boot
mount "$efi_partition" /mnt/boot

# Install base system with selected microcode
echo "Installing base system..."
BASE_PACKAGES="base linux linux-firmware git nano btop fastfetch"

case "$MICROCODE" in
    intel-ucode)
        pacstrap -K /mnt $BASE_PACKAGES intel-ucode
        ;;
    amd-ucode)
        pacstrap -K /mnt $BASE_PACKAGES amd-ucode
        ;;
    *)
        pacstrap -K /mnt $BASE_PACKAGES
        ;;
esac

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "Base system installed and fstab generated."
