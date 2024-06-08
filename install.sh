#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay

# Install NVIDIA Beta drivers. Currently 555.52.04
#yay -S --noconfirm nvidia-beta-dkms opencl-nvidia-beta lib32-opencl-nvidia-beta
yay -S --noconfirm linux-headers nvidia-beta-dkms
# Install latest Hyprland
yay -S --noconfirm hyprland-git 

# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper nwg-look egl-wayland

# Install package & software
sudo pacman -S --noconfirm firefox kitty xsettingsd wget curl nano zip unzip ttf-jetbrains-mono-nerd
yay -S --noconfirm rofi-lbonn-wayland-git nwg-dock-hyprland waybar-git visual-studio-code-bin

# Install Theme,cursors and icons
cd ~ && git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 && cd WhiteSur-gtk-theme && ./install.sh -l && ./tweaks.sh -f && cd.. && rm -rf WhiteSur-gtk-theme
cd ~ && git clone https://github.com/vinceliuice/McMojave-cursors && cd McMojave-cursors && sudo ./install.sh && cd.. && rm -rf McMojave-cursors
cd ~ && git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git && cd Reversal-icon-theme && ./install.sh -a && cd.. && rm -rf Reversal-icon-theme

# Copy files
cd ~ && git clone https://github.com/markox92/dotfiles && cd dotfiles && cp -r .config ~/ && cp -r Wallpapers ~/
mkdir ~/.fonts && git clone https://github.com/epk/SF-Mono-Nerd-Font ~/.fonts && git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts ~/.fonts && fc-cache -f -v

function config_kernel() {
    clear
    printf "Config kernel..."
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf > /dev/null 2>&1
    sudo echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf > /dev/null 2>&1
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img > /dev/null 2>&1
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"/' /etc/default/grub > /dev/null 2>&1
        sudo grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
    fi
    echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/nouveau.conf > /dev/null 2>&1
    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
        echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf"  > /dev/null 2>&1
    else
        echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf" > /dev/null 2>&1
    fi
    echo -e "Done"
}
config_kernel()
