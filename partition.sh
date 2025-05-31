#!/bin/bash

set -e

echo "Listing available drives..."

# List drives
drives=($(lsblk -dno NAME,SIZE | awk '{print "/dev/" $1 " (" $2 ")"}'))
for i in "${!drives[@]}"; do
    echo "$((i+1))) ${drives[$i]}"
done

# Select drive
read -rp "Enter the number of the drive to partition: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#drives[@]} )); then
    echo "Invalid selection."
    exit 1
fi
selected_drive=$(echo "${drives[$((choice-1))]}" | awk '{print $1}')

echo "Selected drive: $selected_drive"
read -rp "Are you sure you want to wipe and partition this drive? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 1
fi

# Ask for mode
echo "Choose partitioning mode:"
echo "1) Auto partition (EFI + SWAP + ROOT)"
echo "2) Manual partition (open cfdisk)"
read -rp "Enter choice [1/2]: " mode

if [[ "$mode" == "2" ]]; then
    echo "Launching cfdisk..."
    cfdisk "$selected_drive"
    exit 0
fi

echo "Wiping existing partitions..."
wipefs -af "$selected_drive"
sgdisk --zap-all "$selected_drive"

echo "Creating new GPT partition table..."
parted -s "$selected_drive" mklabel gpt

# Create partitions
echo "Creating partitions..."
parted -s "$selected_drive" mkpart ESP fat32 1MiB 801MiB
parted -s "$selected_drive" set 1 esp on
parted -s "$selected_drive" mkpart primary linux-swap 801MiB 20801MiB
parted -s "$selected_drive" mkpart primary ext4 20801MiB 100%

echo "Partitions created on $selected_drive:"
lsblk "$selected_drive"