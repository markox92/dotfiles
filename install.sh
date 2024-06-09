#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay

# Install NVIDIA Beta drivers. Currently 555.52.04
cd ~
git clone https://github.com/Frogging-Family/nvidia-all.git
cd nvidia-all
makepkg -si
#yay -S --noconfirm nvidia-beta-dkms opencl-nvidia-beta lib32-opencl-nvidia-beta
# Install latest Hyprland
yay -S --noconfirm hyprland-git 

# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper nwg-look egl-wayland

# Install package & software
sudo pacman -S --noconfirm firefox alacritty xsettingsd wget curl nano zip unzip ttf-jetbrains-mono-nerd
yay -S --noconfirm rofi-lbonn-wayland-git nwg-dock-hyprland waybar-git visual-studio-code-bin

# Install Theme and waybar requirements
sudo pacman -S --noconfirm python-pyquery gnome-themes-extra gtk-engine-murrine sassc 
# Install Theme,cursors and icons
cd ~ && git clone https://github.com/vinceliuice/Colloid-icon-theme && cd Colloid-icon-theme && ./install.sh && cd .. && rm -rf Colloid-icon-theme
cd ~ && git clone https://github.com/vinceliuice/Colloid-gtk-theme && cd Colloid-gtk-theme && ./install.sh -t purple grey blue -c dark --tweaks nord black rimless float -l fixed && cd .. && rm -rf Colloid-gtk-theme
cd ~ && git clone https://github.com/vinceliuice/McMojave-cursors && cd McMojave-cursors && sudo ./install.sh && cd .. && rm -rf McMojave-cursors
#cd ~ && git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git && cd Reversal-icon-theme && ./install.sh -a && cd .. && rm -rf Reversal-icon-theme

# Install fonts
sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
# Check if .fonts directory exists in the home directory
if [ ! -d "$HOME/.fonts" ]; then
    mkdir -p "$HOME/.fonts"
fi
git clone https://github.com/epk/SF-Mono-Nerd-Font ~/fonts && cd ~/fonts && mv *.otf ~/.fonts && cd ~ && rm -rf ~/fonts
git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts ~/fonts && cd ~/fonts && mv *.{otf,ttf} ~/.fonts && cd ~ && rm -rf ~/fonts
fc-cache -f -v

# Copy dotfiles
cd ~/dotfiles
cp -r .config ~/ && cp -r Wallpapers ~/

function config_kernel() {
    printf "Config kernel..."
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/nouveau.conf
    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
        echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf"
    else
        echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf"
    fi
    echo -e "Done"
}
config_kernel


# End remove dotfiles
cd ~ && rm -rf dotfiles
echo "Reboot PC"
