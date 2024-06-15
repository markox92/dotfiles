#!/bin/bash
# Install necessary packages for building from source and the 'yay' AUR helper.
sudo pacman -Syu && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay

# Install NVIDIA Beta drivers. Currently 555.52.04
yay -S --noconfirm linux-headers 
yay -S --noconfirm nvidia-beta-dkms nvidia-utils-beta lib32-nvidia-utils-beta libva-nvidia-driver-git

# Probably don't need it for beta drivers
#yay -S --noconfirm egl-wayland-git

# Install latest Hyprland
yay -S --noconfirm hyprland-git 

# Install hyprpaper, wallpapers support for Hyprland
sudo pacman -S --noconfirm hyprpaper nwg-look

# Install package & software
sudo pacman -S --noconfirm firefox alacritty xsettingsd wget curl nano zip unzip solaar swappy mpv nautilus udisks2 dunst fontconfig
yay -S --noconfirm rofi-lbonn-wayland-git nwg-dock-hyprland nwg-drawer waybar-git visual-studio-code-bin xdg-desktop-portal-hyprland-git

# Install Theme and waybar requirements
sudo pacman -S --noconfirm python-pyquery gnome-themes-extra gtk-engine-murrine sassc sddm qt5-graphicaleffects qt5-svg qt5-quickcontrols2
# Install Theme,cursors and icons
cd ~ && git clone https://github.com/vinceliuice/Colloid-icon-theme && cd Colloid-icon-theme && ./install.sh && cd .. && rm -rf Colloid-icon-theme
cd ~ && git clone https://github.com/vinceliuice/Colloid-gtk-theme && cd Colloid-gtk-theme && ./install.sh -t default -c dark -s standard --tweaks black nord -l fixed && cd .. && rm -rf Colloid-gtk-theme
cd ~ && git clone https://github.com/vinceliuice/WhiteSur-cursors && cd WhiteSur-cursors && ./install.sh && cd .. && rm -rf WhiteSur-cursors

# Install fonts
sudo pacman -S --noconfirm ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts ttf-ubuntu-nerd

# Config terminal
sudo pacman -S --noconfirm zsh
yay -S --noconfirm zsh-autosuggestions zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
mkdir -p ~/.local/share/warp-terminal/themes

# Copy dotfiles
cd ~/dotfiles
yes | cp -rf .config ~/ && cp -r Wallpapers ~/ && cp -r .local ~/
yes | cp -rf .zshrc ~/.zshrc && cp -r .bashrc ~/.bashrc
sudo mkdir -p /usr/local/share/fonts
sudo cp -rf fonts/msfonts/* /usr/local/share/fonts/
sudo fc-cache
sudo mv simple-sddm /usr/share/sddm/themes/
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
sudo systemctl enable sddm.service
# Hide buttons close, min, max
#gsettings set org.gnome.desktop.wm.preferences button-layout :
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'

# End remove dotfiles
cd ~ && rm -rf dotfiles
printf "Reboot PC"
