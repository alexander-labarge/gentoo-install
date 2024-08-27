#!/bin/bash

set -e

DRIVE="/dev/sda"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

echo "Backing up and generating fstab..."

# Backup the current fstab
cp /etc/fstab /etc/fstab.backup

# Start the fstab generation
{
    echo "# /etc/fstab: static file system information."
    echo "#"
    echo "# See fstab(5) for details."
    echo "#"
    echo "# <file system> <mount point>   <type>  <options>       <dump>  <pass>"
} > /etc/fstab

# /efi partition
EFI_UUID=$(blkid -o value -s UUID ${DRIVE}1)
EFI_FSTAB_ENTRY="UUID=${EFI_UUID} /efi vfat defaults 0 2"
echo "$EFI_FSTAB_ENTRY" >> /etc/fstab
echo "Added /efi partition to fstab: $EFI_FSTAB_ENTRY"
ROOT_UUID=$(blkid -o value -s UUID ${DRIVE}2)
ROOT_FSTAB_ENTRY="UUID=${ROOT_UUID} / ext4 defaults 0 1"
echo "Adding / partition to fstab: $ROOT_FSTAB_ENTRY"
echo "$ROOT_FSTAB_ENTRY" >> /etc/fstab

echo "Fstab generation complete. Contents of /etc/fstab:"
cat /etc/fstab
