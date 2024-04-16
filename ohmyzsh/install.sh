#!/usr/bin/bash

set -e

err() {
	echo -e " \e[91m[+]\e[39m $*"
	exit 1
}

! command -v zsh &> /dev/null && err "Install zsh & Try Again!"
! command -v which &> /dev/null && err "Install which & Try Again!"

# Get Username
echo "Username: $USER"
SRC=$(pwd)

# Install ohmyzsh for user
wget -qO installer https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x installer
echo "Installing For $USER"
sudo -u "$USER" bash <<USER
	sh installer
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
	cp -fv .zshrc  ~
	cp -fv .p10k.zsh ~
USER

# Install ohmyzsh for root
echo "Installing For Root"
sudo bash <<ROOT
	cd && cp -v $SRC/installer .
	sh installer
	cp -r "/home/$USER/.oh-my-zsh" .
	cp -fv "$SRC/.zshrc" .
	cp -fv "$SRC/.p10k.zsh" .
ROOT

# Change shell to Zsh
if [[ ! "$SHELL" =~ \zsh$ ]];then
	chsh -s "$(which zsh)"
	sudo chsh -s "$(which zsh)"
fi

echo -e "\n\n"
echo "Restart User Session to load changes!"
