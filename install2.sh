#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
yay -Syu --devel
# Install NVIDIA Beta drivers. Currently 560.31.02-1
yay -S --noconfirm linux-headers 
yay -S --noconfirm nvidia-beta-dkms libva-nvidia-driver-git


# Install latest Hyprland
sudo yay -S --noconfirm hyprland-git
# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper

# Install package & software
sudo pacman -S --noconfirm firefox alacritty kitty wget curl nano zip unzip nautilus neofetch dunst cava
yay -S --noconfirm rofi-lbonn-wayland-git visual-studio-code-bin hyprlock-git 

#sudo mv simple-sddm /usr/share/sddm/themes/
function config_kernel() {
    printf "Config kernel..."
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo echo -e "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
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


#pacman -Sy git
#cd ~
#git clone https://github.com/anthonyprime202/dotfiles
#cd ~/mydots
#yes | cp -rf . ~/.config

printf "Reboot PC"
