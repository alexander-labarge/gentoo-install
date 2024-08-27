#!/bin/bash

#sudo rm -rf /mnt/gentoo
sudo chown -R $USER:$USER /mnt/gentoo && sudo apt-get install wget curl git vim -y
cd /mnt/gentoo
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20240825T170406Z/stage3-amd64-desktop-systemd-20240825T170406Z.tar.xz
sudo tar xpf ./stage3-amd64-desktop-systemd-20240825T170406Z.tar.xz -C /mnt/gentoo --xattrs --numeric-owner
sudo cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

sudo mount --types proc /proc /mnt/gentoo/proc
sudo mount --rbind /sys /mnt/gentoo/sys
sudo mount --make-rslave /mnt/gentoo/sys
sudo mount --rbind /dev /mnt/gentoo/dev
sudo mount --make-rslave /mnt/gentoo/dev
sudo mount --bind /run /mnt/gentoo/run
sudo mount --make-slave /mnt/gentoo/run 

sudo chroot /mnt/gentoo /bin/bash
sudo source /etc/profile
sudo export PS1="(chroot) ${PS1}"
