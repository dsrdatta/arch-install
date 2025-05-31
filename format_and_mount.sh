#!/bin/bash

set -e

if [[ ! -f drive.conf ]]; then
    echo "drive.conf not found. Run partition.sh first."
    exit 1
fi

drive=$(<drive.conf)
efi_part="${drive}1"
swap_part="${drive}2"
root_part="${drive}3"

echo "Formatting partitions on $drive..."
mkfs.fat -F32 "$efi_part"
mkfs.ext4 -F "$root_part"
mkswap "$swap_part"
swapon "$swap_part"

mount "$root_part" /mnt
mkdir -p /mnt/boot
mount "$efi_part" /mnt/boot

echo "Partitions formatted and mounted:"
lsblk
``