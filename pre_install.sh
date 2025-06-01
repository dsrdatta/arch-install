#!/bin/bash
set -e

CYAN='\033[1;36m'
NC='\033[0m' # No Color

LOG_FILE="preinstall_summary.txt"
> "$LOG_FILE" # Clear previous log

echo -e "${CYAN}Logging system state to $LOG_FILE${NC}"

# Log initial lsblk state
{
    echo "### Initial lsblk (before partitioning)"
    lsblk
    echo ""
} >> "$LOG_FILE"

echo -e "${CYAN}Detecting available drives...${NC}"
drives=($(lsblk -dno NAME,SIZE | awk '{print "/dev/" $1 " (" $2 ")"}'))

if [ ${#drives[@]} -eq 0 ]; then
    echo -e "${CYAN}No drives found.${NC}" && exit 1
fi

echo -e "${CYAN}Available drives:${NC}"
for i in "${!drives[@]}"; do
    echo "$((i+1)). ${drives[$i]}"
done

read -rp "Select drive by number: " drive_index
if ! [[ "$drive_index" =~ ^[0-9]+$ ]] || (( drive_index < 1 || drive_index > ${#drives[@]} )); then
    echo -e "${CYAN}Invalid selection.${NC}" && exit 1
fi

selected_drive=$(echo "${drives[$((drive_index-1))]}" | awk '{print $1}')

echo -e "${CYAN}Selected drive: $selected_drive${NC}"
echo "DRIVE=$selected_drive" >> "$LOG_FILE"

echo -e "${CYAN}Choose partitioning mode:${NC}"
echo "1. Automatic (EFI 800M, Swap 20G, Root rest)"
echo "2. Manual"
read -rp "Select partitioning mode (1/2): " part_mode

case "$part_mode" in
    1) partitioning_mode="automatic" ;;
    2) partitioning_mode="manual" ;;
    *) echo -e "${CYAN}Invalid selection${NC}"; exit 1 ;;
esac

echo "PARTITION_MODE=$partitioning_mode" >> "$LOG_FILE"

if [ "$partitioning_mode" == "automatic" ]; then
    echo "Partition layout will be: 800M EFI, 20G Swap, rest Root" >> "$LOG_FILE"
fi

echo -e "${CYAN}Choose CPU type for microcode installation:${NC}"
echo "1. Intel"
echo "2. AMD"
echo "3. Skip microcode"
read -rp "Select option (1/2/3): " cpu_type

case "$cpu_type" in
    1) microcode="intel-ucode" ;;
    2) microcode="amd-ucode" ;;
    3) microcode="none" ;;
    *) echo -e "${CYAN}Invalid selection${NC}"; exit 1 ;;
esac

# Store to both .env and log file
echo "MICROCODE=$microcode" >> .env
echo "MICROCODE=$microcode" >> "$LOG_FILE"

echo -e "\n### You should now run the partitioning script." >> "$LOG_FILE"
echo "### The post-partition lsblk will be logged after partitioning." >> "$LOG_FILE"

echo -e "${CYAN}Pre-installation selections saved to $LOG_FILE${NC}"
