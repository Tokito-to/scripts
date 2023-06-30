#!/usr/bin/env bash

# Exit on any error
set -ex
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
if ! ping -c3 archlinux.org ;then
err "Connect to Internet & try again!" ;fi

# Configuration
prompt "Standard Username [Asuna]: "
read USERNAME
USERNAME=${USERNAME:-asuna}

prompt "User as Root $USERNAME [y/N]: "
read USER_AS_ROOT
[[ "$USER_AS_ROOT" != "y" ]] && USER_AS_ROOT=NO
[[ "$USER_AS_ROOT" = "y" ]] && USER_AS_ROOT=Yes

prompt "User Password [yuuki]: "
read -s USER_PASSWORD
USER_PASSWORD=${USER_PASSWORD:-yuuki}

prompt "Pacman Mirror Country [India]: "
read COUNTRY
COUNTRY=${COUNTRY:-India}

# Configuration
echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Username:" "$USERNAME"
printf "%-16s\t%-16s\n" "User as Root:" "$USER_AS_ROOT"
printf "%-16s\t%-16s\n" "User Password:" "`echo \"$USER_PASSWORD\" | sed 's/./*/g'`"
printf "%-16s\t%-16s\n" "Mirror Country: " "$COUNTRY"
echo ""
prompt "Proceed? [y/N]: "
read PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

# Setup user
useradd -m "$USERNAME"
"echo -e \"$USER_PASSWORD\n$USER_PASSWORD\" | passwd $USERNAME"
if [ "$USER_AS_ROOT" = "Yes" ];then
usermod -aG sudo "$USERNAME" ;fi

# Pacman Configuration
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 4/" "/etc/pacman.conf"
sed -i "s/#Color/Color/" "/etc/pacman.conf"
sed -i "s/#[multilib]/[multilib]/" "/etc/pacman.conf"
sed -i "s/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/" "/etc/pacman.conf"

# Update Mirrors
export TMPFILE="$(mktemp)"
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
curl -L "https://archlinux.org/mirrorlist/all/" > 'mirrorlist'
sed -i 's/^#Server/Server/' 'mirrorlist'
awk '/^## '"$COUNTRY"'$/{f=1; next}f==0{next}/^$/{exit}{print substr($0, 1);}' 'mirrorlist' > "$TMPFILE"
rankmirrors -n 10 "$TMPFILE" > /etc/pacman.d/mirrorlist
pacman -Syy

#Install KDE Plasma Desktop
pacman -Sy --noconfirm plasma-meta plasma-wayland-session
systemctl enable sddm.service


