#!/bin/bash

set -e

DRIVE="/dev/sda"

# Backup the current fstab
cp /etc/fstab /etc/fstab.backup

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Start the fstab generation
{
    echo "# /etc/fstab: static file system information."
    echo "#"
    echo "# See fstab(5) for details."
    echo "#"
    echo "# <file system> <mount point>   <type>  <options>       <dump>  <pass>"
} > /etc/fstab

# /efi partition
EFI_PARTUUID=$(blkid -o value -s PARTUUID ${DRIVE}1)
if [ -z "$EFI_PARTUUID" ]; then
    log "Error: Unable to retrieve PARTUUID for /efi partition."
    exit 1
fi

EFI_FSTAB_ENTRY="PARTUUID=${EFI_PARTUUID} /efi vfat defaults,noatime 0 2"
echo "$EFI_FSTAB_ENTRY" >> /etc/fstab
log "Added /efi partition to fstab: $EFI_FSTAB_ENTRY"

# / root partition
ROOT_PARTUUID=$(blkid -o value -s PARTUUID ${DRIVE}2)
if [ -z "$ROOT_PARTUUID" ]; then
    log "Error: Unable to retrieve PARTUUID for / partition."
    exit 1
fi

ROOT_FSTAB_ENTRY="PARTUUID=${ROOT_PARTUUID} / ext4 defaults,noatime,errors=remount-ro 0 1"
echo "$ROOT_FSTAB_ENTRY" >> /etc/fstab
log "Added / partition to fstab: $ROOT_FSTAB_ENTRY"

log "Fstab generation complete. Contents of /etc/fstab:"
cat /etc/fstab
