#!/usr/bin/bash

set -e

err() {
	echo -e " \e[91m[+]\e[39m $*"
	exit 1
}

# Check package
! command -v jq &> /dev/null && err "jq Not Installed."

# Get Username
echo -n "Github username: "
read -r USERNAME

# Get Github ID
echo "Fetching Id from Github..."
GET_ID() { curl -s https://api.github.com/users/"$USERNAME" | jq '.id'; }
ID=$(GET_ID)

# Check Username
[ "$ID" == "null" ] && err "Invalid Username!"

# Set as Git Global Configs
echo "Global user.email: $ID+$USERNAME@users.noreply.github.com"
git config --global user.email "$ID+$USERNAME@users.noreply.github.com"

echo "Global user.name: $USERNAME"
git config --global user.name "$USERNAME"

echo "nano as Default Editor for Git"
git config --global core.editor nano
