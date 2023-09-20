#!/bin/bash
#
set -eou pipefail
sudo dpkg --add-architecture i386
cd $HOME
sudo apt update
sudo apt install nala -y
sudo nala upgrade -y
sudo nala install unzip alacritty vim git tmux build-essential libxrandr-dev libxft-dev libxinerama-dev lightdm lightdm-gtk-greeter dmenu curl distrobox bluetooth bluez network-manager rsync picom -y
if [ ! -d $HOME/github ]
then
	mkdir github
fi
cd github
set +eou pipefail
git clone https://github.com/rathel/dwm-rathel
git clone https://github.com/rathel/just_scripts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
set -eou pipefail
cd nerd-fonts
if [ ! -d $HOME/.local/share/fonts/NerdFonts ]
then
	./install.sh
fi
cd ../dwm-rathel
./build.sh
if [ ! -d /nix ]
then
	sh <(curl -L https://nixos.org/nix/install) --daemon
fi
if [ ! -f $HOME/.xsessionrc ]
then
	touch $HOME/.xsessionrc
fi
if ! cat $HOME/.xsessionrc | grep .nix-profile/share
then
	echo 'export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS:/usr/share"' >> $HOME/.xsessionrc
fi
if ! cat $HOME/.xsessionrc | grep .nix-profile/bin
then
	echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> $HOME/.xsessionrc
fi
if [ ! -d $HOME/.config/nixpkgs ]
then
	mkdir $HOME/.config/nixpkgs
fi
if [ ! -f $HOME/.config/nixpkgs/config.nix ]
then
	touch $HOME/.config/nixpkgs/config.nix
fi
if ! cat $HOME/.config/nixpkgs/config.nix | grep Unfree
then 
	echo '{ allowUnfree = true; }' >> $HOME/.config/nixpkgs/config.nix
fi
