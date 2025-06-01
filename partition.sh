#!/bin/bash
set -e

# Load selected drive and partitioning mode
if [[ ! -f "preinstall_summary.txt" ]]; then
    echo "Missing preinstall_summary.txt — run pre_install.sh first."
    exit 1
fi

selected_drive=$(grep "^DRIVE=" preinstall_summary.txt | cut -d'=' -f2)
partition_mode=$(grep "^PARTITION_MODE=" preinstall_summary.txt | cut -d'=' -f2)

if [[ -z "$selected_drive" || -z "$partition_mode" ]]; then
    echo "Drive or partitioning mode not found in summary file."
    exit 1
fi

echo "Selected drive: $selected_drive"
echo "Partitioning mode: $partition_mode"

# Manual partitioning
if [[ "$partition_mode" == "manual" ]]; then
    echo "Launching cfdisk for manual partitioning..."
    cfdisk "$selected_drive"
    echo "Manual partitioning complete."
else
    echo "Wiping existing partitions..."
    wipefs -af "$selected_drive"
    sgdisk --zap-all "$selected_drive"

    echo "Creating new GPT partition table..."
    parted -s "$selected_drive" mklabel gpt

    echo "Creating partitions..."
    parted -s "$selected_drive" mkpart ESP fat32 1MiB 801MiB
    parted -s "$selected_drive" set 1 esp on
    parted -s "$selected_drive" mkpart primary linux-swap 801MiB 20801MiB
    parted -s "$selected_drive" mkpart primary ext4 20801MiB 100%

    echo "Auto partitions created on $selected_drive."
fi

# Log post-partition lsblk
echo "" >> preinstall_summary.txt
echo "### lsblk after partitioning" >> preinstall_summary.txt
lsblk >> preinstall_summary.txt

# Save selected drive to separate file if needed
echo "SELECTED_DRIVE=$selected_drive" >> .env
