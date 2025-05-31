#!/bin/bash

set -e

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root." >&2
    exit 1
fi

echo "🔍 Scanning available drives..."
echo
lsblk -dpno NAME,SIZE | grep -v "loop"

# Ask for drive
echo
read -rp "📦 Enter the full path of the drive to partition (e.g., /dev/sda): " DRIVE

# Validate
if [[ ! -b "$DRIVE" ]]; then
    echo "❌ Error: $DRIVE is not a valid block device." >&2
    exit 1
fi

# Confirm
echo "⚠️ WARNING: This will erase all data on $DRIVE!"
read -rp "Type 'YES' to confirm: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    echo "Aborted."
    exit 1
fi

# Partitioning guidance
echo
echo "🧱 Launching cfdisk..."
echo "➡️  Create:"
echo "   1. 800MB EFI System (type: EFI System)"
echo "   2. 20GB Linux swap (type: Linux swap)"
echo "   3. Rest as Linux filesystem"
echo
read -rp "Press Enter to continue..."
cfdisk "$DRIVE"

# Post-partitioning message
echo
echo "✅ Done. Here’s the new layout:"
lsblk "$DRIVE"