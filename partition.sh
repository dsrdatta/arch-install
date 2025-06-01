#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color

# Load selected drive and partitioning mode
if [[ ! -f "preinstall_summary.txt" ]]; then
    echo -e "${CYAN}Missing preinstall_summary.txt — run pre_install.sh first.${NC}"
    exit 1
fi

selected_drive=$(grep "^DRIVE=" preinstall_summary.txt | cut -d'=' -f2)
partition_mode=$(grep "^PARTITION_MODE=" preinstall_summary.txt | cut -d'=' -f2)

if [[ -z "$selected_drive" || -z "$partition_mode" ]]; then
    echo -e "${CYAN}Drive or partitioning mode not found in summary file.${NC}"
    exit 1
fi

echo -e "${CYAN}Selected drive: $selected_drive${NC}"
echo -e "${CYAN}Partitioning mode: $partition_mode${NC}"

# Unmount any mounted partitions under the selected drive
echo -e "${CYAN}Unmounting any mounted partitions on $selected_drive...${NC}"
mounted_parts=$(lsblk -lnpo NAME,MOUNTPOINT "$selected_drive" | awk '$2 != "" { print $1 }')
for part in $mounted_parts; do
    echo -e "${CYAN}Unmounting $part...${NC}"
    umount -f "$part"
done

# Disable swap if any
echo -e "${CYAN}Disabling swap on $selected_drive if any...${NC}"
for part in $(lsblk -lnpo NAME,TYPE "$selected_drive" | awk '$2 == "part" {print $1}'); do
    swapoff "$part" 2>/dev/null || true
done

# Manual or Auto partitioning
if [[ "$partition_mode" == "manual" ]]; then
    echo -e "${CYAN}Launching cfdisk for manual partitioning...${NC}"
    cfdisk "$selected_drive"
    echo -e "${CYAN}Manual partitioning complete.${NC}"
else
    echo -e "${CYAN}Wiping existing partition data...${NC}"
    wipefs -af "$selected_drive"
    sgdisk --zap-all "$selected_drive"

    echo -e "${CYAN}Creating GPT partition table...${NC}"
    parted -s "$selected_drive" mklabel gpt

    echo -e "${CYAN}Creating partitions...${NC}"
    parted -s "$selected_drive" mkpart ESP fat32 1MiB 801MiB
    parted -s "$selected_drive" set 1 esp on
    parted -s "$selected_drive" mkpart primary linux-swap 801MiB 20801MiB
    parted -s "$selected_drive" mkpart primary ext4 20801MiB 100%

    echo -e "${CYAN}Auto partitions created on $selected_drive.${NC}"
fi

# Log partition table to summary
{
    echo ""
    echo "### lsblk after partitioning"
    lsblk
} >> preinstall_summary.txt

# Save selected drive in .env for next scripts
#echo "SELECTED_DRIVE=$selected_drive" >> .env
