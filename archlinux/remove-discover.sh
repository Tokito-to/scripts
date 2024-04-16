#!/usr/bin/bash

# discover is not recomended on arch and arch based distros
# https://discuss.kde.org/t/is-discover-safe-to-use-on-arch-based-distros/8791
# 

#check you sudo
if [[  $EUID -ne 0 ]]; then
        echo "Run with sudo";
        exit 0
fi

#Remove Discover
pacman -Rdd discover

#Add discover to ignore
sed -i "s/#IgnorePkg/IgnorePkg   = discover/"  /etc/pacman.conf
