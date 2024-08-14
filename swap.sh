#!/usr/bin/bash

set -e

#check you sudo
if [[  $EUID -ne 0 ]];then
	echo "Run with sudo";
	exit 0
fi

err() {
	echo -e " \e[91m*\e[39m $*"
	exit 1
}

prompt() {
	echo -ne " \e[92m*\e[39m $*"
}

if [[ -n "$(command swapon --show)" ]];then
  swapon --show
  err "Swap Already Exist. Exiting"
fi

prompt "Customize Swap Location[N/y]: "
read -r CSWAP
[[ "$CSWAP" != "y" ]] && CSWAP=No || CSWAP=Yes

if [[ "$CSWAP" == "Yes" ]];then
  df -h --output='target','fstype','size','used','avail'
  prompt "Swap Location[/]: "
  read -r SWAPLOC
  [[ ! -d "$SWAPLOC" ]] && err "Partition Does Not exist. Exiting"
  SWAP="$SWAPLOC/swapfile"
else
  SWAP="/swapfile"
fi

STORAGE=$(df -h "/$SWAPLOC" | awk '/\// {print $4}')

echo "Your current Avail Space for $SWAP : ${STORAGE}"
prompt "Swap Size[G]: "
read -r SWAP_SIZE

if [[ ! "$SWAP_SIZE" =~ ^[0-9]+[GM]$ ]];then
  echo "Enter Swap size with it's prefix i.e G,M specified"
  prompt "Swap Size[G]: "
  read -r SWAP_SIZE
  [[ ! "$SWAP_SIZE" =~ ^[0-9]+[GM]$ ]] && err "Invalid Swap Size"
fi

echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Custom Swap Location:" "$CSWAP"
printf "%-16s\t%-16s\n" "Swap Location:" "$SWAP"
printf "%-16s\t%-16s\n" "Swap Size:" "$SWAP_SIZE"
echo ""
prompt "Proceed? [y/N]: "
read -r PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

echo "Creating SwapFile "
swapon --show
fallocate -l "$SWAP_SIZE" "$SWAP"
chmod 600 "$SWAP"
ls -lh "$SWAP"
mkswap "$SWAP"
swapon "$SWAP"
swapon --show
cp -v /etc/fstab /etc/fstab.bak
echo -e "\n# $SWAP" >> /etc/fstab
echo "$SWAP none swap sw 0 0" | tee -a /etc/fstab

echo ""
echo "Swap successfuly created!"
