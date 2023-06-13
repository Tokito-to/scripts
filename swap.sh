#!/usr/bin/bash

#check you sudo
if [[  $EUID -ne 0 ]]; then
        echo "Run with sudo";
        exit 0
fi

STORAGE=$(df -h | awk '/\/$/ {print $4}')
echo "Your current Root Avail space : ${STORAGE}"
echo "Swap Size:[G]"
read -r SWAP_SIZE

 echo "creating swapfile "
         swapon --show
         fallocate -l "$SIZE" /swapfile
         ls -lh /swapfile
         chmod 600 /swapfile
         mkswap /swapfile
         swapon /swapfile
         swapon --show
         cp /etc/fstab /etc/fstab.bak
       echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
