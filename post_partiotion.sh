BOOT_DRIVE=/dev/nvme0n1p6
ROOT_DRIVE=/dev/nvme0n1p7
LUKS_DRIVE_NAME=luks
LUKS_DRIVE=/dev/mapper/${LUKS_DRIVE_NAME}
PROC_UCODE=amd-ucode

mkfs.vfat ${BOOT_DRIVE}
cryptsetup luksFormat ${ROOT_DRIVE}
cryptsetup luksOpen ${ROOT_DRIVE} ${LUKS_DRIVE_NAME}

mkfs.btrfs -f ${LUKS_DRIVE}

mount ${LUKS_DRIVE} /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@var
btrfs sub create /mnt/@var_log
btrfs sub create /mnt/@snapshots
cd /
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@ ${LUKS_DRIVE} /mnt
mkdir -p /mnt/{boot,home,var,var_log,.snapshots}

mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@home ${LUKS_DRIVE} /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@var ${LUKS_DRIVE} /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@var_log ${LUKS_DRIVE} /mnt/var_log
mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@snapshots ${LUKS_DRIVE} /mnt.snapshots
mount ${BOOT_DRIVE} /mnt/boot

pacstrap /mnt base linux linux-firmware vim ${PROC_UCODE} git btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab

cp -r /arch-basic/postinstall /mnt/postinstall
chmod +x /mnt/postinstall/install-uefi.sh

arch-chroot /mnt /bin/bash /mnt/postinstall/install-uefi.sh