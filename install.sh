#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay

# Install NVIDIA Beta drivers. Currently 555.52.04
yay -S --noconfirm nvidia-beta-dkms

# egl-wayland provides the necessary compatibility layer, instead of falling back to zink/Vulkan for proprietary drivers.
yay -S --noconfirm egl-wayland-git

# Install latest Hyprland
yay -S --noconfirm hyprland-git 

# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper nwg-look

# Install package & software
sudo pacman -S --noconfirm firefox alacritty xsettingsd wget curl nano zip unzip solaar zsh
yay -S --noconfirm rofi-lbonn-wayland-git nwg-dock-hyprland waybar-git visual-studio-code-bin

# Install Theme and waybar requirements
sudo pacman -S --noconfirm python-pyquery gnome-themes-extra gtk-engine-murrine sassc 
# Install Theme,cursors and icons
cd ~ && git clone https://github.com/vinceliuice/Colloid-icon-theme && cd Colloid-icon-theme && ./install.sh && cd .. && rm -rf Colloid-icon-theme
cd ~ && git clone https://github.com/vinceliuice/Colloid-gtk-theme && cd Colloid-gtk-theme && ./install.sh -t default -c dark -s standard --tweaks black nord -l fixed && cd .. && rm -rf Colloid-gtk-theme
cd ~ && git clone https://github.com/vinceliuice/WhiteSur-cursors && cd WhiteSur-cursors && sudo ./install.sh && cd .. && rm -rf WhiteSur-cursors
#cd ~ && git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git && cd Reversal-icon-theme && ./install.sh -a && cd .. && rm -rf Reversal-icon-theme

# Install fonts
sudo pacman -S --noconfirm ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts
# Check if .fonts directory exists in the home directory
if [ ! -d "$HOME/.fonts" ]; then
    mkdir -p "$HOME/.fonts"
fi
#git clone https://github.com/epk/SF-Mono-Nerd-Font ~/fonts && cd ~/fonts && mv *.otf ~/.fonts && cd ~ && rm -rf ~/fonts
#git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts ~/fonts && cd ~/fonts && mv *.{otf,ttf} ~/.fonts && cd ~ && rm -rf ~/fonts
#fc-cache -f -v

# Copy dotfiles
mkdir -p ~/.local/share/warp-terminal/themes
cd ~/dotfiles
cp -r .config ~/ && cp -r Wallpapers ~/ && cp -r .local ~/


function config_kernel() {
    printf "Config kernel..."
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo echo -e "options nvidia-drm modeset=1 NVreg_RegistryDwords=\"PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3\"" | sudo tee -a /etc/modprobe.d/nvidia.conf
    sudo mkinitcpio -P
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0 nvidia_drm.fbdev=1"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    printf "Done"
}
config_kernel

sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service
# Hide buttons close, min, max
gsettings set org.gnome.desktop.wm.preferences button-layout :

# End remove dotfiles
cd ~ && rm -rf dotfiles
printf "Reboot PC"
