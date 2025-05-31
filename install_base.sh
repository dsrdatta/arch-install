#!/bin/bash
set -e

if [[ ! -f drive.conf ]]; then
    echo "Error: drive.conf not found. Run partition.sh first."
    exit 1
fi

echo "Installing base system with pacstrap..."

pacstrap -K /mnt base linux linux-firmware sudo git nano btop fastfetch networkmanager

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Base system installed and fstab generated."
