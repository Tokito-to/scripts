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

#Install KDE Plasma Desktop
pacman -Sy --noconfirm plasma-meta plasma-wayland-session konsole

#Install Additional Utils
pacman -Sy --noconfirm dolphin kate zsh ark android-tools ntfs-3g

#Remove unwanted packages
pacman -Rdd --noconfirm discover plasma-welcome
sed -i "s/#IgnorePkg   =/IgnorePkg   = discover plasma-welcome/" "/etc/pacman.conf" #useless on arch kde

# Install Waterfox-G-Kpe
echo '
## Prebuilt Waterfox Repo
[home_hawkeye116477_waterfox_Arch]
Server = https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch' >> /etc/pacman.conf
#Install Key
key=$(curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/Arch/$(uname -m)/home_hawkeye116477_waterfox_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"
pacman -Sy --noconfirm home_hawkeye116477_waterfox_Arch/waterfox-g-kpe

# Install configs
git clone https://github.com/Tokito-Kun/scripts/ -b configs
mkdir -p "/etc/sddm.conf.d/"
mkdir -p "/home/$USERNAME/.config/"
cp -fv "scripts/kcminputrc" "/home/$USERNAME/.config/"
cp -fv "scripts/kde_settings.conf" "/etc/sddm.conf.d/"
systemctl enable sddm.service

# ohmyszh Install
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
cp -v "scripts/.zshrc" "/home/$USERNAME/"
cp -v "scripts/.p10k.zsh" "/home/$USERNAME/"
./scripts/ohmyzsh.sh
