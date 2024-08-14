#!/usr/bin/bash

set -e

# Run as Root
if [[  $EUID -ne 0 ]];then
	echo "Run as root";
	exit 1
fi

pacman -S --noconfirm --needed os-prober efibootmgr grub breeze-grub

sed -i "/GRUB_DISABLE_OS_PROBER=false/"'s/^#//' /etc/default/grub
sed -i 's/\(GRUB_DISTRIBUTOR="\)[^"]*"/\1'\''Arch Linux'\''"/' /etc/default/grub
sed -i 's/#\(GRUB_THEME="\)[^"]*"/\1\/usr\/share\/grub\/themes\/breeze\/theme.txt"/' /etc/default/grub
sed -i "s/version_sort -r/version_sort -V/" /etc/grub.d/10_linux
sed -i 's/OS="${GRUB_DISTRIBUTOR} Linux"/OS="${GRUB_DISTRIBUTOR}"/' /etc/grub.d/10_linux
sed -i 's/Loading Linux/Loading ${OS}/' /etc/grub.d/10_linux
echo '# Reboot
menuentry "Restart" {
	echo "System rebooting..."
	reboot
}

# Shutdown
menuentry "Shutdown" {
	echo "System shutting down..."
	halt
}' >>  /etc/grub.d/40_custom

grub-mkconfig -o /boot/grub/grub.cfg
