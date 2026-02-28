#!/bin/bash
# Qarvix ISO Build Script
# Builds a bootable ISO based on Void Linux with Sway + runit
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_ROOT}/out"
ROOTFS="${BUILD_DIR}/rootfs"
ISO_OUT="${BUILD_DIR}/qarvix-$(date +%Y%m%d).iso"
VOID_MIRROR="https://repo-default.voidlinux.org/current"
ARCH="x86_64"
VERBOSE="${VERBOSE:-0}"

log() { echo "[qarvix] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }
run() { [[ "$VERBOSE" == "1" ]] && set -x; "$@"; { [[ "$VERBOSE" == "1" ]] && set +x; } 2>/dev/null; }

check_deps() {
    local deps=(xbps-install xbps-reconfigure xbps-uhelper mksquashfs xorriso)
    for cmd in "${deps[@]}"; do
        command -v "$cmd" >/dev/null || die "Missing: $cmd"
    done
    [[ $EUID -eq 0 ]] || die "Must run as root"
}

bootstrap_rootfs() {
    log "Bootstrapping Void Linux rootfs..."
    mkdir -p "$ROOTFS/var/db/xbps/keys"

    # Copy host xbps signing keys to target rootfs
    cp /var/db/xbps/keys/*.plist "$ROOTFS/var/db/xbps/keys/" 2>/dev/null || true

    # Also set up repo config in rootfs
    mkdir -p "$ROOTFS/etc/xbps.d"
    echo "repository=$VOID_MIRROR" > "$ROOTFS/etc/xbps.d/00-repository-main.conf"
    echo "repository=${VOID_MIRROR}/nonfree" >> "$ROOTFS/etc/xbps.d/00-repository-main.conf"

    yes | XBPS_ARCH="$ARCH" xbps-install -S -r "$ROOTFS" \
        -R "$VOID_MIRROR" -y \
        base-minimal || true

    # Mount pseudo-filesystems
    mount --bind /dev "$ROOTFS/dev"
    mount --bind /proc "$ROOTFS/proc"
    mount --bind /sys "$ROOTFS/sys"
    trap cleanup EXIT
}

install_packages() {
    log "Installing packages..."
    local pkg_file="${PROJECT_ROOT}/packages/packages.conf"
    [[ -f "$pkg_file" ]] || die "Missing $pkg_file"

    local pkgs=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [[ -n "$line" ]] && pkgs+=("$line")
    done < "$pkg_file"

    yes | XBPS_ARCH="$ARCH" xbps-install -S -r "$ROOTFS" \
        -R "$VOID_MIRROR" -y "${pkgs[@]}" || true
}

configure_system() {
    log "Configuring system..."

    # Hostname
    echo "qarvix" > "$ROOTFS/etc/hostname"

    # Locale
    echo "en_US.UTF-8 UTF-8" > "$ROOTFS/etc/default/libc-locales"
    chroot "$ROOTFS" xbps-reconfigure -f glibc-locales

    # Timezone
    chroot "$ROOTFS" ln -sf /usr/share/zoneinfo/UTC /etc/localtime

    # Copy configs
    cp -r "${PROJECT_ROOT}/config/sway" "$ROOTFS/etc/sway"
    cp -r "${PROJECT_ROOT}/config/runit/services/"* "$ROOTFS/etc/sv/" 2>/dev/null || true
    cp "${PROJECT_ROOT}/config/kernel/cmdline.conf" "$ROOTFS/etc/default/grub.d/" 2>/dev/null || true
    cp "${PROJECT_ROOT}/config/macbook/"* "$ROOTFS/etc/modprobe.d/" 2>/dev/null || true

    # Greetd login manager
    mkdir -p "$ROOTFS/etc/greetd"
    cp "${PROJECT_ROOT}/config/greetd/config.toml" "$ROOTFS/etc/greetd/"

    # Foot terminal
    mkdir -p "$ROOTFS/etc/xdg/foot"
    cp "${PROJECT_ROOT}/config/foot/foot.ini" "$ROOTFS/etc/xdg/foot/"

    # GTK theme
    mkdir -p "$ROOTFS/etc/gtk-3.0"
    cp "${PROJECT_ROOT}/config/gtk-3.0/settings.ini" "$ROOTFS/etc/gtk-3.0/"

    # Neovim
    mkdir -p "$ROOTFS/etc/xdg/nvim"
    cp "${PROJECT_ROOT}/config/nvim/init.lua" "$ROOTFS/etc/xdg/nvim/"

    # Zsh + Starship
    cp "${PROJECT_ROOT}/config/zsh/.zshrc" "$ROOTFS/etc/skel/.zshrc"
    mkdir -p "$ROOTFS/etc/xdg"
    cp "${PROJECT_ROOT}/config/zsh/starship.toml" "$ROOTFS/etc/xdg/starship.toml"

    # GRUB theme
    mkdir -p "$ROOTFS/boot/grub/themes/qarvix"
    cp "${PROJECT_ROOT}/config/grub-theme/theme.txt" "$ROOTFS/boot/grub/themes/qarvix/"

    # Zellij
    mkdir -p "$ROOTFS/etc/xdg/zellij"
    cp "${PROJECT_ROOT}/config/zellij/config.kdl" "$ROOTFS/etc/xdg/zellij/"

    # Git config
    mkdir -p "$ROOTFS/etc/skel"
    cp "${PROJECT_ROOT}/config/git/gitconfig" "$ROOTFS/etc/skel/.gitconfig"

    # Enable runit services
    for svc in iwd dhcpcd dbus pipewire seatd greetd docker; do
        ln -sf "/etc/sv/$svc" "$ROOTFS/etc/runit/runsvdir/default/" 2>/dev/null || true
    done

    # Default shell
    chroot "$ROOTFS" chsh -s /bin/zsh root

    # GRUB config
    cat > "$ROOTFS/etc/default/grub" <<'GRUB'
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Qarvix"
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 i915.enable_psr=1 i915.enable_fbc=1"
GRUB_THEME="/boot/grub/themes/qarvix/theme.txt"
GRUB

}

apply_branding() {
    log "Applying branding..."
    mkdir -p "$ROOTFS/etc/qarvix"
    cp "${PROJECT_ROOT}/branding/motd" "$ROOTFS/etc/motd" 2>/dev/null || true
    cp "${PROJECT_ROOT}/branding/os-release" "$ROOTFS/etc/os-release" 2>/dev/null || true

    # Install Rust tools if available
    for bin in qarvix-ctl qarvix-dev; do
        if [[ -f "/usr/local/bin/$bin" ]]; then
            cp "/usr/local/bin/$bin" "$ROOTFS/usr/local/bin/"
        elif [[ -f "${PROJECT_ROOT}/qarvix-tools/target/release/$bin" ]]; then
            cp "${PROJECT_ROOT}/qarvix-tools/target/release/$bin" "$ROOTFS/usr/local/bin/"
        fi
    done
    chmod +x "$ROOTFS/usr/local/bin/qarvix-"* 2>/dev/null || true

    # Auto-update daemon
    cp "${PROJECT_ROOT}/build/qarvix-autoupdate" "$ROOTFS/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS/usr/local/bin/qarvix-autoupdate" 2>/dev/null || true
}

build_iso() {
    log "Building ISO..."
    mkdir -p "${BUILD_DIR}/iso/boot/grub" "${BUILD_DIR}/iso/live"

    # Create squashfs
    mksquashfs "$ROOTFS" "${BUILD_DIR}/iso/live/filesystem.squashfs" \
        -comp zstd -Xcompression-level 19 -b 1M -no-duplicates

    # Copy kernel and initramfs
    cp "$ROOTFS"/boot/vmlinuz-* "${BUILD_DIR}/iso/boot/vmlinuz"
    cp "$ROOTFS"/boot/initramfs-* "${BUILD_DIR}/iso/boot/initrd.img"

    # GRUB config for ISO
    cat > "${BUILD_DIR}/iso/boot/grub/grub.cfg" <<'EOF'
set timeout=3
set default=0

menuentry "Qarvix Live" {
    linux /boot/vmlinuz boot=live quiet loglevel=3
    initrd /boot/initrd.img
}

menuentry "Qarvix Live (safe mode)" {
    linux /boot/vmlinuz boot=live nomodeset
    initrd /boot/initrd.img
}
EOF

    # Build ISO
    xorriso -as mkisofs \
        -iso-level 3 \
        -o "$ISO_OUT" \
        -full-iso9660-filenames \
        -volid "QARVIX" \
        --grub2-boot-info \
        --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
        -eltorito-boot boot/grub/bios.img \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
        -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
        -append_partition 2 0xef "${BUILD_DIR}/iso/EFI/efiboot.img" \
        "${BUILD_DIR}/iso"

    log "ISO built: $ISO_OUT"
}

cleanup() {
    log "Cleaning up..."
    umount -lf "$ROOTFS/dev" 2>/dev/null || true
    umount -lf "$ROOTFS/proc" 2>/dev/null || true
    umount -lf "$ROOTFS/sys" 2>/dev/null || true
}

main() {
    log "Building Qarvix ISO..."
    check_deps
    bootstrap_rootfs
    install_packages
    configure_system
    apply_branding
    build_iso
    log "Done!"
}

main "$@"
