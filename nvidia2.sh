#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
yay -Syu --devel
# Install NVIDIA Beta drivers. Currently 560.31.02-1
yay -S --noconfirm linux-headers 
yay -S --noconfirm nvidia-beta-dkms libva-nvidia-driver-git

yay -S --noconfirm hyprland-meta-git
# Install package & software
sudo pacman -S --noconfirm firefox zip unzip
yay -S visual-studio-code-bin
#sudo mv simple-sddm /usr/share/sddm/themes/
function config_kernel() {
    printf "Config kernel..."
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo echo -e "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
    sudo mkinitcpio -P
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    printf "Done"
}
config_kernel
printf "Reboot PC"
