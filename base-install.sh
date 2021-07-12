#This step should running first

mkfs.vfat /dev/nvme0n1p6
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/nvme0n1p7
cryptsetup luksOpen /dev/nvme0n1p7 luks

mkfs.btrfs -f /dev/mapper/luks

mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@var
btrfs sub create /mnt/@var_log
btrfs sub create /mnt/@snapshots
cd /
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@ /dev/mapper/luks /mnt
mkdir -p /mnt/{boot,home,var,var_log,.snapshots}

mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@home /dev/mapper/luks /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@var /dev/mapper/luks /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@var_log /dev/mapper/luks /mnt/var_log
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@snapshots /dev/mapper/luks /mnt.snapshots
mount /dev/nvme0n1p6 /mnt/boot

pacstrap /mnt base linux linux-firmware vim amd-ucode git btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab

cp -r /arch-basic/postinstall /mnt/postinstall
chmod +x /mnt/postinstall/install-uefi.sh

arch-chroot /mnt /bin/bash /mnt/postinstall/install-uefi.sh