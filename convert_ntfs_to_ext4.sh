#!/bin/bash

# Script to convert a partition from NTFS to ext4
# WARNING: This will erase all data on the specified partition!
# Run this script in a Fedora Live USB or rescue mode to avoid "disk in use" errors.

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1 || error_exit "$1 is not installed. Please install it."
}

# Check required commands
check_command fdisk
check_command mkfs.ext4
check_command blkid
check_command partprobe
check_command lsblk

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root (use sudo)."
fi

# Check if running in a live or rescue environment
if [ -d "/run/media" ] || grep -q "rescue" /proc/cmdline; then
    echo -e "${GREEN}Running in a safe environment (live USB or rescue mode).${NC}"
else
    echo -e "${YELLOW}Warning: This script should be run in a Fedora Live USB or rescue mode to avoid disk in use errors.${NC}"
    read -p "Continue anyway? (y/N): " confirm
    [[ "$confirm" =~ ^[yY]$ ]] || error_exit "Aborted by user."
fi

# Prompt for partition
if [ -z "$1" ]; then
    echo "Usage: $0 <partition> (e.g., /dev/sda4)"
    echo "Available partitions:"
    lsblk -f | grep -E 'ntfs|ext4'
    read -p "Enter the partition to convert (e.g., /dev/sda4): " PARTITION
else
    PARTITION="$1"
fi

# Validate partition exists
if [ ! -b "$PARTITION" ]; then
    error_exit "Partition $PARTITION does not exist."
fi

# Get disk device (e.g., /dev/sda from /dev/sda4)
DISK=$(echo "$PARTITION" | sed -r 's/([[:alpha:]]+)[[:digit:]]+/\1/')
if [ ! -b "/dev/$DISK" ]; then
    error_exit "Disk /dev/$DISK not found."
fi

# Check if partition is NTFS
PART_TYPE=$(blkid -o value -s TYPE "$PARTITION" 2>/dev/null)
if [ "$PART_TYPE" != "ntfs" ]; then
    error_exit "$PARTITION is not an NTFS partition (found type: $PART_TYPE)."
fi

# Check if partition is mounted
if mount | grep -q "$PARTITION"; then
    echo -e "${YELLOW}Partition $PARTITION is mounted. Attempting to unmount...${NC}"
    umount "$PARTITION" || error_exit "Failed to unmount $PARTITION."
fi

# Check if any swap partitions are active on the disk
if swapon --show | grep -q "/dev/$DISK"; then
    echo -e "${YELLOW}Swap partition detected on /dev/$DISK. Disabling swap...${NC}"
    swapoff -a || error_exit "Failed to disable swap."
fi

# Prompt for backup confirmation
echo -e "${RED}WARNING: Converting $PARTITION to ext4 will ERASE ALL DATA on this partition!${NC}"
read -p "Have you backed up all data on $PARTITION? (y/N): " backup_confirm
[[ "$backup_confirm" =~ ^[yY]$ ]] || error_exit "Aborted. Please back up your data first."

# Get partition details (start and end sectors)
PART_INFO=$(fdisk -l "/dev/$DISK" | grep "$PARTITION")
START_SECTOR=$(echo "$PART_INFO" | awk '{print $2}')
END_SECTOR=$(echo "$PART_INFO" | awk '{print $3}')
if [ -z "$START_SECTOR" ] || [ -z "$END_SECTOR" ]; then
    error_exit "Could not determine start and end sectors for $PARTITION."
fi
PART_NUMBER=$(echo "$PARTITION" | grep -o '[0-9]\+$')

echo -e "${GREEN}Partition details:${NC}"
echo "Partition: $PARTITION"
echo "Disk: /dev/$DISK"
echo "Start sector: $START_SECTOR"
echo "End sector: $END_SECTOR"
echo "Partition number: $PART_NUMBER"

# Confirm before proceeding
read -p "Proceed with converting $PARTITION to ext4? (y/N): " proceed_confirm
[[ "$proceed_confirm" =~ ^[yY]$ ]] || error_exit "Aborted by user."

# Modify partition with fdisk
echo -e "${YELLOW}Modifying partition table...${NC}"
{
    echo "d"           # Delete partition
    echo "$PART_NUMBER" # Partition number
    echo "n"           # Create new partition
    echo "p"           # Primary partition
    echo "$PART_NUMBER" # Partition number
    echo "$START_SECTOR" # Start sector
    echo "$END_SECTOR"   # End sector
    echo "t"           # Change partition type
    echo "$PART_NUMBER" # Partition number
    echo "83"          # Linux filesystem (ext4)
    echo "w"           # Write changes
} | fdisk "/dev/$DISK" || error_exit "Failed to modify partition table."

# Update kernel partition table
echo -e "${YELLOW}Updating kernel partition table...${NC}"
partprobe "/dev/$DISK" || error_exit "Failed to update partition table."

# Format partition as ext4
echo -e "${YELLOW}Formatting $PARTITION as ext4...${NC}"
mkfs.ext4 -F "$PARTITION" || error_exit "Failed to format $PARTITION as ext4."

# Verify the new filesystem
NEW_TYPE=$(blkid -o value -s TYPE "$PARTITION" 2>/dev/null)
if [ "$NEW_TYPE" != "ext4" ]; then
    error_exit "Verification failed: $PARTITION is not ext4 (found type: $NEW_TYPE)."
fi

echo -e "${GREEN}Success: $PARTITION has been converted to ext4!${NC}"
echo "Next steps:"
echo "1. Mount the partition (e.g., sudo mkdir /mnt/ext4; sudo mount $PARTITION /mnt/ext4)"
echo "2. Restore your backed-up data."
echo "3. Update /etc/fstab if needed (e.g., add: $PARTITION /mnt/ext4 ext4 defaults 0 2)"
echo "4. Reboot your system."

exit 0
