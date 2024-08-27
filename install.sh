#!/bin/bash

# after drive partition + file system creation

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
source /etc/profile
export PS1="(chroot) ${PS1}"

emerge-webrsync
emerge --sync

# UPDATE COMPILER FLAGS

cp /etc/portage/make.conf /etc/portage/make.conf.bak2
OPTIMIZED_FLAGS="$(gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | sed -n 's/.*-march=\([a-z]*\)/-march=\1/p' | sed 's/-dumpbase null//')"

if [ -z "${OPTIMIZED_FLAGS}" ]; then
    einfo "Failed to extract optimized CPU flags"
    exit 1
fi

# Remove trailing space in COMMON_FLAGS
COMMON_FLAGS=$(echo "${COMMON_FLAGS}" | sed 's/ *$//')

# Update COMMON_FLAGS in make.conf
sed -i "/^COMMON_FLAGS/c\COMMON_FLAGS=\"-O2 -pipe ${OPTIMIZED_FLAGS}\"" /etc/portage/make.conf
sed -i 's/COMMON_FLAGS="\(.*\)"/COMMON_FLAGS="\1"/;s/  */ /g' /etc/portage/make.conf

# Assign MAKEOPTS automatically
NUM_CORES=$(nproc)
MAKEOPTS_VALUE=$((NUM_CORES + 1))
echo "MAKEOPTS=\"-j${MAKEOPTS_VALUE}\"" >> /etc/portage/make.conf

echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf
echo 'VIDEO_CARDS="nvidia"' >> /etc/portage/make.conf
echo 'USE="X"' >> /etc/portage/make.conf

eselect profile set default/linux/amd64/23.0/desktop/gnome/systemd
emerge --oneshot app-portage/cpuid2cpuflags
cpuid2cpuflags 
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

emerge --ask --verbose --update --deep --newuse @world

# update localtime
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# uncomment en_US.UTF-8 UTF-8
nano /etc/locale.gen

locale-gen
eselect locale list # - pick the one next
eselect locale set 4
# example:
# (chroot) xwing-7760 /usr/share/zoneinfo/America # ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
# (chroot) xwing-7760 /usr/share/zoneinfo/America # eselect locale list
# Available targets for the LANG variable:
#   [1]   C
#   [2]   C.utf8
#   [3]   POSIX
#   [4]   C.UTF8 *
#   [ ]   (free form)
# (chroot) xwing-7760 /usr/share/zoneinfo/America # nano /etc/local
# locale.conf  locale.gen   localtime    
# (chroot) xwing-7760 /usr/share/zoneinfo/America # nano /etc/local
# locale.conf  locale.gen   localtime    
# (chroot) xwing-7760 /usr/share/zoneinfo/America # nano /etc/locale.gen 
# (chroot) xwing-7760 /usr/share/zoneinfo/America # locale-gen
#  * Generating 2 locales (this might take a while) with 16 jobs
#  *  (2/2) Generating C.UTF-8 ...                                                                                         [ ok ]
#  *  (1/2) Generating en_US.UTF-8 ...                                                                                     [ ok ]
#  * Generation complete
#  * Adding locales to archive ...                                                                                         [ ok ]
# (chroot) xwing-7760 /usr/share/zoneinfo/America # eselect locale list
# Available targets for the LANG variable:
#   [1]   C
#   [2]   C.utf8
#   [3]   POSIX
#   [4]   en_US.utf8
#   [5]   C.UTF8 *
#   [ ]   (free form)
# (chroot) xwing-7760 /usr/share/zoneinfo/America # eselect locale set 4
# Setting LANG to en_US.utf8 ...
# Run ". /etc/profile" to update the variable in your shell.
# (chroot) xwing-7760 /usr/share/zoneinfo/America # env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
# >>> Regenerating /etc/ld.so.cache...
# (chroot) xwing-7760 /usr/share/zoneinfo/America # 

# Kernel Config

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --verbose --autounmask-continue=y sys-kernel/gentoo-sources
emerge --verbose --autounmask-continue=y sys-kernel/linux-firmware
emerge --verbose --autounmask-continue=y sys-kernel/genkernel
