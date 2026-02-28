# Qarvix ⚡

A lightweight Linux distribution built on **Void Linux** with **Sway** and **runit**, optimized for the MacBook Air 2017.

## Vision

Breathe new life into aging hardware. Qarvix boots in under 5 seconds, idles under 300MB RAM, and gives you a modern Wayland desktop that flies.

## Tech Stack

| Component | Choice | Why |
|-----------|--------|-----|
| Base | Void Linux | Minimal, independent, no systemd bloat |
| Init | runit | Fastest boot, simplest supervision |
| Display | Sway (Wayland) | Tiling WM, GPU-efficient, modern |
| Shell | zsh | Fast, powerful, great defaults |
| Terminal | foot | Wayland-native, minimal footprint |
| Launcher | fuzzel | Wayland-native app launcher |
| Bar | waybar | Customizable, lightweight status bar |
| Audio | PipeWire | Modern, low-latency audio |
| Network | iwd + dhcpcd | Lightweight WiFi + DHCP |
| Firewall | nftables | Modern, minimal firewall |

## MacBook Air 2017 Support

- Intel HD 6000 graphics (i915 driver)
- Broadcom WiFi (brcmfmac)
- Keyboard backlight control
- Trackpad gestures (libinput)
- Fan control (mbpfan)
- Battery optimization (TLP)
- EFI boot (GRUB2)

## Project Structure

```
qarvix/
├── build/              # ISO build scripts
│   └── build-iso.sh    # Main ISO generation script
├── config/
│   ├── sway/           # Sway WM configuration
│   ├── runit/          # runit service definitions
│   ├── kernel/         # Kernel parameters & modules
│   └── macbook/        # MacBook-specific hardware config
├── packages/           # Package lists
│   └── packages.conf   # Base + desktop + dev packages
├── branding/           # Boot splash, GTK theme, wallpaper
├── installer/          # Custom installer script
├── docs/               # Documentation
└── Makefile            # Build automation
```

## Quick Start

```bash
# Build the ISO
make iso

# Build with verbose output
make iso VERBOSE=1

# Clean build artifacts
make clean
```

## Requirements

- Void Linux host (or any Linux with xbps)
- ~10GB free disk space
- Internet connection for package downloads

## License

MIT
