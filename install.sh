#!/bin/bash
# Install SUDO
pacman -S sudo

# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay

# Install NVIDIA Beta drivers. Currently 555.52.04
yay -S --noconfirm nvidia-beta-dkms opencl-nvidia-beta lib32-opencl-nvidia-beta

# Install latest Hyprland
yay -S hyprland-git 

# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper nwg-look

# Install package & software
sudo pacman -S --noconfirm firefox kitty xsettingsd wget curl nano zip unzip ttf-jetbrains-mono-nerd
yay -S --noconfir rofi-lbonn-wayland-git nwg-dock-hyprland waybar-git visual-studio-code-bin

# Install Theme,cursors and icons
cd ~ && git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 && cd WhiteSur-gtk-theme && ./install.sh -l && ./tweaks.sh -f && cd.. && rm -rf WhiteSur-gtk-theme
cd ~ && git clone https://github.com/vinceliuice/McMojave-cursors && cd McMojave-cursors && sudo ./install.sh && cd.. && rm -rf McMojave-cursors
cd ~ && git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git && cd Reversal-icon-theme && ./install.sh -a && cd.. && rm -rf Reversal-icon-theme

# Copy files
cd ~ && git clone https://github.com/markox92/dotfiles && cd dotfiles && cp -r .config ~/ && cp -r Wallpapers ~/
mkdir ~/.fonts && git clone https://github.com/epk/SF-Mono-Nerd-Font ~/.fonts && git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts ~/.fonts && fc-cache -f -v
