#!/usr/bin/env bash

# Exit on any error
set -e
clear

err() {
	echo -e " \e[91m*\e[39m $*"
	exit 1
}

prompt() {
	echo -ne " \e[92m*\e[39m $*"
}

# check you Superuser Permissions
if [[  $EUID -ne 0 ]]; then
        echo "Run with sudo";
        exit 0 ;fi

# Chech Internet Connection
if ! ping -c1 archlinux.org ;then
err "Connect to Internet & try again!" ;fi

# Configuration
prompt "Standard Username [asuna]: "
read USERNAME
USERNAME=${USERNAME:-asuna}

prompt "User Password [yuuki]: "
read -s USER_PASSWORD
USER_PASSWORD=${USER_PASSWORD:-yuuki}

prompt "User as Root $USERNAME [y/N]: "
read USER_AS_ROOT
[[ "$USER_AS_ROOT" != "y" ]] && USER_AS_ROOT=NO
[[ "$USER_AS_ROOT" = "y" ]] && USER_AS_ROOT=Yes

# Configuration
echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Username:" "$USERNAME"
printf "%-16s\t%-16s\n" "User Password:" "`echo \"$USER_PASSWORD\" | sed 's/./*/g'`"
printf "%-16s\t%-16s\n" "User as Root:" "$USER_AS_ROOT"

echo ""
prompt "Proceed? [y/N]: "
read PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

set -x

# Instal and Setup sudo
pacman -Sy --noconfirm sudo
groupadd sudo

# Setup user
useradd -m "$USERNAME"
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME
if [ "$USER_AS_ROOT" = "Yes" ];then
usermod -aG sudo "$USERNAME" ;fi

# Don't ask passwd for sudo superuser # only for $USERNAME
echo "## Allow $USERNAME to execute any root command
%$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Pacman Configuration
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 4/" "/etc/pacman.conf"
sed -i "s/#Color/Color/" "/etc/pacman.conf"
sed -i "s/#IgnorePkg   =/IgnorePkg   = discover plasma-welcome/" "/etc/pacman.conf" #useless on arch kde

#Install KDE Plasma Desktop
pacman -Sy --noconfirm plasma-meta plasma-wayland-session konsole
systemctl enable sddm.service

#Install Additional Utils
pacman -Sy --noconfirm dolphin kate zsh ark

# Install Waterfox-G-Kpe
echo "
## Prebuilt Waterfox Repo
[home_hawkeye116477_waterfox_Arch]
Server = https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch" >> /etc/pacman.conf
#Install Key
key=$(curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/Arch/$(uname -m)/home_hawkeye116477_waterfox_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"
pacman -Sy home_hawkeye116477_waterfox_Arch/waterfox-g-kpe
