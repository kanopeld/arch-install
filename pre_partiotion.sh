#!/bin/bash

timedatectl set-ntp true
pacman -Syy --noconfirm reflector openssh
echo root:toor | chpasswd
systemctl start sshd.service
reflector -c Poland -a 6 --sort rate --save /etc/pacman.d/mirrorlists