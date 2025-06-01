#!/bin/bash
set -e

LOG_FILE="preinstall_summary.txt"
> "$LOG_FILE" # Clear previous log

echo "Logging system state to $LOG_FILE"

# Log initial lsblk state
echo "### Initial lsblk (before partitioning)" >> "$LOG_FILE"
lsblk >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "Detecting available drives..."
drives=($(lsblk -dno NAME,SIZE | awk '{print "/dev/" $1 " (" $2 ")"}'))

if [ ${#drives[@]} -eq 0 ]; then
    echo "No drives found." && exit 1
fi

echo "Available drives:"
for i in "${!drives[@]}"; do
    echo "$((i+1)). ${drives[$i]}"
done

read -rp "Select drive by number: " drive_index
selected_drive=$(echo "${drives[$((drive_index-1))]}" | awk '{print $1}')
echo "Selected drive: $selected_drive"
echo "DRIVE=$selected_drive" >> "$LOG_FILE"

echo "Choose partitioning mode:"
echo "1. Automatic (EFI 800M, Swap 20G, Root rest)"
echo "2. Manual"
read -rp "Select partitioning mode (1/2): " part_mode

case "$part_mode" in
    1)
        partitioning_mode="automatic"
        ;;
    2)
        partitioning_mode="manual"
        ;;
    *)
        echo "Invalid selection"; exit 1
        ;;
esac

echo "PARTITION_MODE=$partitioning_mode" >> "$LOG_FILE"

if [ "$partitioning_mode" == "automatic" ]; then
    echo "Partition layout will be: 800M EFI, 20G Swap, rest Root" >> "$LOG_FILE"
fi

echo "Choose CPU type for microcode installation:"
echo "1. Intel"
echo "2. AMD"
echo "3. Skip microcode"
read -rp "Select option (1/2/3): " cpu_type

case "$cpu_type" in
    1)
        microcode="intel-ucode"
        ;;
    2)
        microcode="amd-ucode"
        ;;
    3)
        microcode="none"
        ;;
    *)
        echo "Invalid selection"; exit 1
        ;;
esac

echo "MICROCODE=$microcode" >> .env
echo "MICROCODE=$microcode" >> "$LOG_FILE"

# Mark end of pre-install section
echo "" >> "$LOG_FILE"
echo "### You should now run the partitioning script." >> "$LOG_FILE"
echo "### The post-partition lsblk will be logged after partitioning." >> "$LOG_FILE"

echo "Pre-installation selections saved to $LOG_FILE"
