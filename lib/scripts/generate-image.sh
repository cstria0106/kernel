#!/bin/bash

# This script will generate Arch Linux based Linux file system image
# Usage: ./generate-image.sh <filename> [size]

FILENAME=$1
SIZE=$2

set -e

if [ -z "$FILENAME" ]; then
    echo "Usage: ./generate-image.sh <filename> [size]"
    echo "Example: ./generate-image.sh linux.img 32G"
    exit 1
fi

if [ -z "$SIZE" ]; then
    SIZE=32G
fi

if [ -e "$FILENAME" ]; then
    echo "The file '$FILENAME' is already exists"
    exit 1
fi

echo "Start create $SIZE image to $FILENAME"

echo "Creating image..."
qemu-img create -f raw "$FILENAME" "$SIZE"

echo "Creating file system..."
mkfs.ext4 "$FILENAME"

echo "Mounting image..."
mkdir mount
sudo mount "$FILENAME" mount

echo "Setup Arch Linux system on guest..."
sudo pacstrap mount

echo "Running initialize script for guest..."
cat ./lib/scripts/initialize-guest.sh | sudo arch-chroot mount

echo "Unmounting image..."
sudo umount mount # Unmount guest root
rm -r mount