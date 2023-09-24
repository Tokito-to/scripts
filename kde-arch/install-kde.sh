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
	echo "Run with sudo"
	exit 0;fi

# Chech Internet Connection
if ! ping -c1 archlinux.org ;then
	err "Connect to Internet & try again!";fi

# Configuration
prompt "Standard Username [asuna]: "
read USERNAME
USERNAME=${USERNAME:-asuna}

prompt "User Password [yuuki]: "
read -s USER_PASSWORD
USER_PASSWORD=${USER_PASSWORD:-yuuki} && echo

prompt "User as Root $USERNAME [y/N]: "
read USER_AS_ROOT
[[ "$USER_AS_ROOT" != "y" ]] && USER_AS_ROOT=NO
[[ "$USER_AS_ROOT" = "y" ]] && USER_AS_ROOT=Yes

# Configuration
echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Username:" "$USERNAME"
printf "%-16s\t%-16s\n" "User Password:" "$(echo "$USER_PASSWORD" | sed 's/./*/g')"
printf "%-16s\t%-16s\n" "User as Root:" "$USER_AS_ROOT"

echo ""
prompt "Proceed? [y/N]: "
read PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

# Instal and Setup sudo
pacman -Sy --noconfirm --needed sudo
groupadd sudo

# Setup user
useradd -m "$USERNAME"
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME
if [ "$USER_AS_ROOT" = "Yes" ];then
	usermod -aG sudo "$USERNAME";fi

# Don't ask passwd for sudo superuser # only for $USERNAME
echo "## Allow $USERNAME to execute any root command
%$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Pacman Configuration
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 4/" "/etc/pacman.conf"
sed -i "s/#Color/Color/" "/etc/pacman.conf"

#Install KDE Plasma Desktop
pacman -Sy --noconfirm --needed plasma-meta plasma-wayland-session konsole
systemctl enable sddm.service

#Install Additional Utils
pacman -Sy --noconfirm --needed dolphin kate zsh ark android-tools ntfs-3g

#Remove unwanted packages
pacman -Rdd --noconfirm discover plasma-welcome
sed -i "s/#IgnorePkg   =/IgnorePkg   = discover plasma-welcome/" "/etc/pacman.conf" #useless on arch kde

# Install Waterfox-G-Kpe
echo '
## Prebuilt Waterfox Repo
[home_hawkeye116477_waterfox_Arch]
Server = https://downloadcontent.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch
Server = https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch' >> /etc/pacman.conf
#Install Key
key=$(curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/Arch/$(uname -m)/home_hawkeye116477_waterfox_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"
pacman -Sy --noconfirm --needed waterfox-g-kpe

# Persepolis Download Manger
wget https://github.com/Tokito-Kun/aur-package-builder/releases/download/v2021.12.17-2/youtube-dl-2021.12.17-2-any.pkg.tar.zst
pacman -U --noconfirm youtube-dl-2021.12.17-2-any.pkg.tar.zst 
pacman -Sy --noconfirm --needed aria2 python-setuptools kwallet persepolis #kwallet required by persepolis

# Custom configs
git config --global core.editor nano
git clone https://github.com/Tokito-Kun/scripts/ -b configs config
rm -rf "config/.git"
# Persepolis Config
mkdir -p "/home/$USERNAME/.waterfox/native-messaging-hosts/"
cp -v "config/com.persepolis.pdmchromewrapper.json" "/home/$USERNAME/.waterfox/native-messaging-hosts/"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.waterfox/"
# KDE Tweaks
mkdir -p "/etc/sddm.conf.d/"
mkdir -p "/home/$USERNAME/.config/"
cp -fv "config/kde_settings.conf" "/etc/sddm.conf.d/"
cp -fv "config/kcminputrc" "/home/$USERNAME/.config/"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
rm -rf scripts
# Copy to user
mkdir -p "/home/$USERNAME/git"
cp -rv "config" "/home/$USERNAME/git"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/git"
su $USERNAME <<EOF
git clone https://github.com/Tokito-Kun/scripts/ ~/git/scripts
EOF
