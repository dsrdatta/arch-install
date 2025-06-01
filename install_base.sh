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

if [[ -z "$SELECTED_DRIVE" ]]; then
    echo -e "${CYAN}Error: SELECTED_DRIVE not set. Run partition.sh first.${NC}"
    exit 1
fi

selected_drive="$SELECTED_DRIVE"
efi_partition="${selected_drive}1"
swap_partition="${selected_drive}2"
root_partition="${selected_drive}3"

echo -e "${CYAN}Formatting partitions...${NC}"
mkfs.fat -F32 "$efi_partition"
mkswap "$swap_partition"
swapon "$swap_partition"
mkfs.ext4 "$root_partition"

echo -e "${CYAN}Mounting root and EFI partitions...${NC}"
mount "$root_partition" /mnt
mkdir -p /mnt/boot
mount "$efi_partition" /mnt/boot

# Install base system with selected microcode
echo -e "${CYAN}Installing base system...${NC}"
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

echo -e "${CYAN}Generating fstab...${NC}"
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "${CYAN}Base system installed and fstab generated.${NC}"