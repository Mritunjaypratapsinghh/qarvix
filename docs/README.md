# Qarvix Documentation

## Getting Started

### Requirements
- MacBook Air 2017 (or any x86_64 machine with EFI)
- USB drive (4GB+)
- Internet connection

### Download
Get the latest ISO from [GitHub Releases](https://github.com/Mritunjaypratapsinghh/qarvix/releases).

### Create Bootable USB
```bash
# Linux/macOS
sudo dd if=qarvix-*.iso of=/dev/sdX bs=4M status=progress

# Or use Balena Etcher
```

### Boot
1. Insert USB into MacBook
2. Hold **Option (⌥)** key during boot
3. Select **EFI Boot**
4. Choose **Qarvix Live** from GRUB menu

### Install
```bash
sudo qarvix-install -d /dev/sda -u yourusername -t America/New_York
```

---

## Desktop Usage

### Keybindings

| Key | Action |
|-----|--------|
| `Super + Enter` | Open terminal |
| `Super + D` | App launcher |
| `Super + Shift+Q` | Close window |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + 1-5` | Switch workspace |
| `Super + Shift+1-5` | Move window to workspace |
| `Super + F` | Fullscreen |
| `Super + R` | Resize mode |
| `Super + Escape` | Lock screen |
| `Print` | Screenshot (clipboard) |
| `Super + Print` | Screenshot (region) |

### System Control
```bash
# WiFi
qarvix-ctl wifi list
qarvix-ctl wifi connect "NetworkName"

# Brightness
qarvix-ctl brightness up
qarvix-ctl brightness set 70

# Volume
qarvix-ctl volume up
qarvix-ctl volume mute

# Battery
qarvix-ctl battery

# Power profiles
qarvix-ctl power saving       # max battery
qarvix-ctl power balanced     # default
qarvix-ctl power performance  # max speed

# Updates
qarvix-ctl update check
qarvix-ctl update install
```

---

## Developer Tools

### Project Scaffolding
```bash
qarvix-dev init myapp --template rust
qarvix-dev init api --template node
qarvix-dev init ml --template python
qarvix-dev init service --template go
qarvix-dev templates    # list all
```

### Dev Environments
```bash
qarvix-dev up       # start containers from qarvix-dev.toml
qarvix-dev status   # show running
qarvix-dev down     # stop all
```

### qarvix-dev.toml
```toml
name = "myapp"

[services.db]
image = "postgres:16-alpine"
ports = ["5432:5432"]
env = { POSTGRES_PASSWORD = "dev" }

[services.redis]
image = "redis:alpine"
ports = ["6379:6379"]
```

### Terminal Multiplexer (Zellij)
| Key | Action |
|-----|--------|
| `Alt + N` | New pane |
| `Alt + D` | Split down |
| `Alt + R` | Split right |
| `Alt + W` | Close pane |
| `Alt + T` | New tab |
| `Alt + 1-5` | Switch tab |
| `Alt + H/J/K/L` | Navigate panes |
| `Alt + F` | Fullscreen pane |

### Editor (Neovim)
| Key | Action |
|-----|--------|
| `Space + FF` | Find files |
| `Space + FG` | Grep search |
| `Space + FB` | Buffers |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `Space + CA` | Code action |
| `Space + RN` | Rename |
| `Tab/S-Tab` | Autocomplete navigate |

### Pre-installed Tools
`git` `neovim` `docker` `rustup` `nodejs` `python3` `go` `zellij` `lazygit` `ripgrep` `fd` `bat` `fzf` `jq` `delta` `tokei`

---

## Building from Source

```bash
git clone https://github.com/Mritunjaypratapsinghh/qarvix.git
cd qarvix

# Check project structure
make check

# Build ISO (requires Void Linux host + root)
make iso

# Build Rust tools only
cd qarvix-tools && cargo build --release
```

---

## Architecture

```
User → Sway (Wayland) → Waybar + Foot + Fuzzel
         ↓
    Qarvix Tools (Rust)
    qarvix-ctl | qarvix-dev
         ↓
    iwd | PipeWire | TLP | mbpfan
         ↓
    runit (init)
         ↓
    Linux Kernel (Void)
    i915 | brcmfmac | libinput
         ↓
    MacBook Air 2017 Hardware
```
