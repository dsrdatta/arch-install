#!/bin/bash
set -e

# Colors
CYAN='\033[1;36m'
NC='\033[0m'

# Detect available drives (excluding loop, rom, etc.)
mapfile -t drives < <(lsblk -dnp -o NAME,SIZE,TYPE | grep 'disk' | awk '{print $1 " (" $2 ")"}')

if [[ ${#drives[@]} -eq 0 ]]; then
    echo -e "${CYAN}No physical drives found.${NC}"
    exit 1
fi

echo -e "${CYAN}Available drives:${NC}"
for i in "${!drives[@]}"; do
    echo -e "${CYAN}[$((i+1))] ${drives[$i]}${NC}"
done

read -rp "$(echo -e "${CYAN}Select a drive (1-${#drives[@]}): ${NC}")" drive_index

if ! [[ "$drive_index" =~ ^[0-9]+$ ]] || (( drive_index < 1 || drive_index > ${#drives[@]} )); then
    echo -e "${CYAN}Invalid selection.${NC}"
    exit 1
fi

# Extract drive name (e.g., /dev/sda)
selected_drive=$(echo "${drives[$((drive_index-1))]}" | awk '{print $1}')

# Ask for partitioning mode
echo -e "${CYAN}Partitioning modes:${NC}"
echo -e "${CYAN}[1] Auto${NC}"
echo -e "${CYAN}[2] Manual (uses cfdisk)${NC}"
read -rp "$(echo -e "${CYAN}Select partitioning mode [1-2]: ${NC}")" mode

case "$mode" in
    1) partition_mode="auto" ;;
    2) partition_mode="manual" ;;
    *) echo -e "${CYAN}Invalid selection.${NC}"; exit 1 ;;
esac

# Optional microcode selection
echo -e "${CYAN}CPU Microcode:${NC}"
echo -e "${CYAN}[1] Intel${NC}"
echo -e "${CYAN}[2] AMD${NC}"
echo -e "${CYAN}[3] Skip${NC}"
read -rp "$(echo -e "${CYAN}Select microcode option [1-3]: ${NC}")" microcode_choice

case "$microcode_choice" in
    1) microcode="intel-ucode" ;;
    2) microcode="amd-ucode" ;;
    3) microcode="" ;;
    *) echo -e "${CYAN}Invalid selection.${NC}"; exit 1 ;;
esac

# Save configuration
echo "DRIVE=$selected_drive" > preinstall_summary.txt
echo "PARTITION_MODE=$partition_mode" >> preinstall_summary.txt
echo "MICROCODE=$microcode" >> preinstall_summary.txt

# Also save to .env for other scripts
#echo "SELECTED_DRIVE=$selected_drive" > .env
#echo "PARTITION_MODE=$partition_mode" >> .env
#echo "MICROCODE=$microcode" >> .env

echo -e "${CYAN}Drive and partitioning preferences saved.${NC}"