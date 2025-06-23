#!/bin/bash
set -e
CYAN='\033[1;36m'
NC='\033[0m' # No color

# Load selected drive from .env
SELECTED_DRIVE=$(grep "^DRIVE=" preinstall_summary.txt | cut -d'=' -f2)
if [[ -z "$SELECTED_DRIVE" ]]; then
    echo -e "${CYAN}Error: SELECTED_DRIVE not set. Run partition.sh first.${NC}"
    exit 1
fi

drive="$SELECTED_DRIVE"

# Function to get partition names based on drive type
get_partition_name() {
    local drive=$1
    local partition_num=$2

    # Drives that use 'p' prefix for partitions
    if [[ $drive == *"nvme"* ]] ||
        [[ $drive == *"mmcblk"* ]] ||
        [[ $drive == *"loop"* ]] ||
        [[ $drive == *"dm-"* ]]; then
        echo "${drive}p${partition_num}"
    else
        # Traditional drives (sda, vda, xvda, hda, etc.)
        echo "${drive}${partition_num}"
    fi
}

# Get partition names
efi_part=$(get_partition_name "$drive" "1")
swap_part=$(get_partition_name "$drive" "2")
root_part=$(get_partition_name "$drive" "3")

echo -e "${CYAN}Detected drive type: $drive${NC}"
echo -e "${CYAN}Partition layout:${NC}"
echo -e "${CYAN}  EFI:  $efi_part${NC}"
echo -e "${CYAN}  Swap: $swap_part${NC}"
echo -e "${CYAN}  Root: $root_part${NC}"

echo -e "${CYAN}Formatting partitions on $drive...${NC}"
mkfs.fat -F32 "$efi_part"
mkfs.ext4 -F "$root_part"
mkswap "$swap_part"
swapon "$swap_part"

echo -e "${CYAN}Mounting partitions...${NC}"
mount "$root_part" /mnt
mkdir -p /mnt/boot
mount "$efi_part" /mnt/boot

echo -e "${CYAN}Partitions formatted and mounted:${NC}"
lsblk

# Log partition table to summary
{
    echo ""
    echo "### lsblk after partitioning, formatting & mounting"
    lsblk
} >>preinstall_summary.txt
