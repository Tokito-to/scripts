#!/usr/bin/bash

set -e

#Get Username
echo "Github username:"
read -r USERNAME

#Get Github ID
GET_ID() { curl -s https://api.github.com/users/"$USERNAME" | jq '.id'; }
ID=$(GET_ID) 

#Set Git Global Config
git config --global user.email "$ID+$USERNAME@users.noreply.github.com"
git config --global user.name "$USERNAME"
