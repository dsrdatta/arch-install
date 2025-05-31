#!/bin/bash
set -e

# Simple logging functions
log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*"; }
error() { echo "[ERROR] $*" >&2; }

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root."
    exit 1
fi

log "Scanning available drives..."
lsblk -dpno NAME,SIZE | grep -v "loop"

echo
read -rp "[INPUT] Enter the full path of the drive to partition (e.g., /dev/sda): " DRIVE

if [[ ! -b "$DRIVE" ]]; then
    error "$DRIVE is not a valid block device."
    exit 1
fi

warn "This will erase all data on $DRIVE!"
read -rp "Type 'YES' to confirm: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    log "Aborted by user."
    exit 1
fi

echo
log "Launching cfdisk..."
echo "--> Create:"
echo "    1. 800MB EFI System (type: EFI System)"
echo "    2. 20GB Linux swap (type: Linux swap)"
echo "    3. Rest as Linux filesystem"
echo
read -rp "Press Enter to continue..."
cfdisk "$DRIVE"

echo
log "Partitioning complete. Layout:"
lsblk "$DRIVE"