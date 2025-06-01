#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No color


# Load environment variables
SELECTED_DRIVE=$(grep "^DRIVE=" preinstall_summary.txt | cut -d'=' -f2)

# Install base system with selected microcode
echo -e "${CYAN}Installing base system...${NC}"
BASE_PACKAGES="base linux linux-firmware networkmanager sudo git nano btop fastfetch"

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