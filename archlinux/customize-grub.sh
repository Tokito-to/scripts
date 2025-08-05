#!/usr/bin/bash

set -e

# Run as Root
if [[  $EUID -ne 0 ]];then
     echo "Run as root";
     exit 1
fi

# Install Packages
pacman -S --noconfirm --needed grub breeze-grub

# Enable OS-Prober
sed -i "/GRUB_DISABLE_OS_PROBER=false/"'s/^#//' /etc/default/grub

# Set GRUB_DISTRIBUTOR to 'Arch Linux'
sed -i 's/\(GRUB_DISTRIBUTOR="\)[^"]*"/\1'\''Arch Linux'\''"/' /etc/default/grub

# Set Grub Theme (Breeze by KDE)
sed -i 's/#\(GRUB_THEME="\)[^"]*"/\1\/usr\/share\/grub\/themes\/breeze\/theme.txt"/' /etc/default/grub

# Use Version Sort (To get Linux at top of the list)
sed -i "s/version_sort -r/version_sort -V/" /etc/grub.d/10_linux

# Display Distro Name on Load
sed -i 's/OS="${GRUB_DISTRIBUTOR} Linux"/OS="${GRUB_DISTRIBUTOR}"/' /etc/grub.d/10_linux
sed -i 's/Loading Linux/Loading ${OS}/' /etc/grub.d/10_linux

# Restart MenuEntry to Grub
if grep -q "menuentry \"Restart\"" /etc/grub.d/40_custom; then
     echo "Restart Entry Already Exists."
else
echo '# Reboot
menuentry "Restart" {
     echo "System rebooting..."
     reboot
}' >>  /etc/grub.d/40_custom
fi

# Shutdown MenuEntry To Grub
if grep -q "menuentry \"Shutdown\"" /etc/grub.d/40_custom; then
     echo "Shutdown Entry Already Exists."
else
echo '# Shutdown
menuentry "Shutdown" {
     echo "System shutting down..."
     halt
}' >>  /etc/grub.d/40_custom
fi

# Generate Grub Config
grub-mkconfig -o /boot/grub/grub.cfg
