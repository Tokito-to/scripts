#!/usr/bin/bash

set -e

# Check package
if [[ -z $(command -v jq) ]]; then
  echo "jq Not Installed."
  exit 1
fi

# Get Username
echo -n "Github username: "
read -r USERNAME

# Get Github ID
echo "Fetching Id from Github..."
GET_ID() { curl -s https://api.github.com/users/"$USERNAME" | jq '.id'; }
ID=$(GET_ID)

# Check Username
if [ "$ID" == "null" ]; then
  echo "Invalid Username!"
  exit 1
fi

# Set as Git Global Configs
echo "Global user.email: $ID+$USERNAME@users.noreply.github.com"
#git config --global user.email "$ID+$USERNAME@users.noreply.github.com"

echo "Global user.name: $USERNAME"
#git config --global user.name "$USERNAME"

echo "nano as Default Editor for Git"
#git config --global core.editor nano
