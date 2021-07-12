#!/bin/bash

USERNAME=kanopeld

ln -sf /usr/share/zoneinfo/Europe/Minsk /etc/localtime
hwclock --systohc
localectl set-locale LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts

pacman -S grub grub-btrfs efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font

# pacman -S --noconfirm xf86-video-amdgpu
pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

cd /tmp
git clone https://aur.archlinux.org/paru
cd ./paru
mkpkg -si
cd

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB_UEFI --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

useradd -m ${USERNAME}
echo ${USERNAME}:password | chpasswd
usermod -aG libvirt ${USERNAME}
usermod -aG wheel ${USERNAME}

sed -i 's/#%wheel/%wheel/' /etc/sudoers

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"




