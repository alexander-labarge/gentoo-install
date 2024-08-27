#!/bin/bash

#sudo rm -rf /mnt/gentoo
sudo chown -R $USER:$USER /mnt/gentoo && sudo apt-get install wget curl git vim -y
cd /mnt/gentoo
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20240825T170406Z/stage3-amd64-desktop-systemd-20240825T170406Z.tar.xz
sudo tar xpf ./stage3-amd64-desktop-systemd-20240825T170406Z.tar.xz -C /mnt/gentoo --xattrs --numeric-owner
