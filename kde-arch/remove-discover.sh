#!/usr/bin/bash 

#check you sudo
if [[  $EUID -ne 0 ]]; then
        echo "Run with sudo";
        exit 0
fi 

#Remove Discover
pacman -Rdd discover

#Add discover to ignore
sed -i "s/#IgnorePkg/IgnorePkg   = discover/"  /etc/pacman.conf 
