#!/bin/bash
# Qarvix Installer - Installs Qarvix to disk
set -euo pipefail

log() { echo "[qarvix-install] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }

DISK=""
HOSTNAME="qarvix"
USERNAME=""
TIMEZONE="UTC"

usage() {
    cat <<EOF
Usage: qarvix-install [OPTIONS]

Options:
  -d, --disk DEVICE     Target disk (e.g., /dev/sda)
  -u, --user NAME       Username to create
  -t, --timezone TZ     Timezone (default: UTC)
  -h, --help            Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--disk) DISK="$2"; shift 2 ;;
        -u|--user) USERNAME="$2"; shift 2 ;;
        -t|--timezone) TIMEZONE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) die "Unknown option: $1" ;;
    esac
done

[[ $EUID -eq 0 ]] || die "Must run as root"
[[ -n "$DISK" ]] || die "Specify target disk with -d"
[[ -n "$USERNAME" ]] || die "Specify username with -u"
[[ -b "$DISK" ]] || die "$DISK is not a block device"

confirm() {
    echo "WARNING: This will ERASE ALL DATA on $DISK"
    read -rp "Type 'yes' to continue: " ans
    [[ "$ans" == "yes" ]] || die "Aborted"
}

partition_disk() {
    log "Partitioning $DISK (GPT + EFI)..."
    parted -s "$DISK" \
        mklabel gpt \
        mkpart ESP fat32 1MiB 512MiB \
        set 1 esp on \
        mkpart root btrfs 512MiB 100%

    mkfs.fat -F32 "${DISK}1"
    mkfs.btrfs -f "${DISK}2"
}

mount_target() {
    log "Mounting filesystems..."
    mount "${DISK}2" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    mount -o subvol=@,compress=zstd,noatime "${DISK}2" /mnt
    mkdir -p /mnt/{home,boot/efi}
    mount -o subvol=@home,compress=zstd,noatime "${DISK}2" /mnt/home
    mount "${DISK}1" /mnt/boot/efi
}

install_system() {
    log "Installing Qarvix..."
    unsquashfs -f -d /mnt /run/live/medium/live/filesystem.squashfs
}

configure_install() {
    log "Configuring installed system..."

    # fstab
    genfstab -U /mnt > /mnt/etc/fstab

    # hostname
    echo "$HOSTNAME" > /mnt/etc/hostname

    # timezone
    chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

    # user
    chroot /mnt useradd -m -G wheel,seat,video,audio -s /bin/zsh "$USERNAME"
    log "Set password for $USERNAME:"
    chroot /mnt passwd "$USERNAME"

    # sudo
    echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel

    # GRUB
    chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=qarvix
    chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

main() {
    confirm
    partition_disk
    mount_target
    install_system
    configure_install
    log "Installation complete! Reboot into Qarvix."
}

main
