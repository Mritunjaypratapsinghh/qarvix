# Qarvix - Project Plan

## Vision

A lightweight Linux distro that makes a MacBook Air 2017 feel brand new.

## Core Promises

| Promise | Target |
|---------|--------|
| Boot time | < 5 seconds |
| Idle RAM | < 300MB |
| Battery life | 8+ hours |
| Desktop | Beautiful Wayland tiling (Sway) |
| Hardware | Everything works out of the box |
| Install | One command |

## Tech Stack

| Component | Choice |
|-----------|--------|
| Base | Void Linux |
| Init | runit |
| Desktop | Sway (Wayland) |
| Shell | zsh |
| Terminal | foot |
| Bar | waybar |
| Audio | PipeWire |
| Network | iwd + dhcpcd |
| Languages | Rust (tools) + Bash (glue) |

## Architecture

```
┌─────────────────────────────────────────┐
│              User Space                  │
│                                          │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ │
│  │  Sway   │ │  Waybar  │ │   Foot   │ │
│  │  (WM)   │ │  (Bar)   │ │  (Term)  │ │
│  └────┬────┘ └────┬─────┘ └────┬─────┘ │
│       │           │             │        │
│  ┌────┴───────────┴─────────────┴─────┐ │
│  │         Wayland (Compositor)       │ │
│  └────────────────┬───────────────────┘ │
│                   │                      │
│  ┌────────────────┴───────────────────┐ │
│  │     Qarvix Tools (Rust)            │ │
│  │  qarvix-ctl | qarvix-install       │ │
│  └────────────────┬───────────────────┘ │
│                   │                      │
│  ┌──────┬─────────┼──────────┬────────┐ │
│  │ iwd  │ PipeWire│  TLP     │ mbpfan │ │
│  │(WiFi)│ (Audio) │(Battery) │ (Fan)  │ │
│  └──┬───┴────┬────┴─────┬───┴───┬────┘ │
│     └────────┴──────────┴───────┘       │
│              runit (init)                │
├─────────────────────────────────────────┤
│           Linux Kernel (Void)            │
│     i915 | brcmfmac | libinput          │
├─────────────────────────────────────────┤
│        MacBook Air 2017 Hardware         │
│   Intel i5 | 8GB | SSD | Broadcom WiFi  │
└─────────────────────────────────────────┘
```

## Phases

### Phase 1: Foundation ✅
- [x] Project structure
- [x] Void Linux base + Sway + runit
- [x] Package list (60+ packages)
- [x] MacBook hardware configs (WiFi, GPU, fan, battery)
- [x] ISO build script
- [x] Basic installer (Bash)
- [x] Branding (os-release, MOTD)
- [x] Sway config with MacBook keybindings
- [x] Waybar config + Tokyo Night theme
- [x] Makefile

### Phase 2: Rust Tooling
- [ ] Set up Rust workspace (`qarvix-tools/`)
- [ ] `qarvix-ctl` - System control CLI
  - [ ] `qarvix-ctl wifi list/connect/disconnect`
  - [ ] `qarvix-ctl brightness get/set/up/down`
  - [ ] `qarvix-ctl volume get/set/up/down/mute`
  - [ ] `qarvix-ctl battery status`
  - [ ] `qarvix-ctl update` (xbps wrapper)
  - [ ] `qarvix-ctl power performance/balanced/saving`
- [ ] `qarvix-install` - TUI installer
  - [ ] Disk selection + partitioning (GPT + EFI + btrfs)
  - [ ] User creation
  - [ ] Timezone/locale selection
  - [ ] GRUB install
- [ ] `qarvix-welcome` - First-boot wizard
  - [ ] User setup
  - [ ] Theme selection
  - [ ] Keyboard layout

### Phase 3: Desktop Polish
- [ ] Custom GRUB theme (Qarvix splash)
- [ ] Login manager (greetd + tuigreet)
- [ ] GTK theme (dark, consistent)
- [ ] Custom wallpapers
- [ ] Notification styling (mako)
- [ ] Swaylock theme
- [ ] Font rendering optimization
- [ ] Auto-detect MacBook model

### Phase 4: Developer Experience
- [ ] Pre-installed dev tools (git, neovim, docker, rust)
- [ ] `qarvix-dev` command for dev environments
- [ ] Zellij (terminal multiplexer) config
- [ ] Neovim config (LSP, treesitter, minimal)

### Phase 5: Distribution
- [ ] GitHub releases with ISO downloads
- [ ] Website (qarvix.dev)
- [ ] Documentation site
- [ ] Auto-update system
- [ ] Community channels (Discord/Matrix)
- [ ] DistroWatch submission

## Priority Order

1. Phase 2 → `qarvix-ctl` (proves the concept)
2. Phase 3 → Desktop polish (makes it feel real)
3. Phase 2 → TUI installer (needed for real installs)
4. Phase 4 → Dev tools
5. Phase 5 → Ship it

## Target Hardware

| Spec | MacBook Air 2017 |
|------|-----------------|
| CPU | Intel Core i5-5350U |
| RAM | 8GB LPDDR3 |
| Storage | 128/256GB SSD |
| GPU | Intel HD Graphics 6000 |
| WiFi | Broadcom BCM4360 |
| Display | 1440x900 |
| Boot | EFI |

## File Structure

```
qarvix/
├── Makefile
├── README.md
├── PLAN.md              ← You are here
├── build/
│   └── build-iso.sh
├── config/
│   ├── sway/
│   ├── runit/services/
│   ├── kernel/
│   └── macbook/
├── packages/
│   └── packages.conf
├── branding/
│   ├── os-release
│   └── motd
├── installer/
│   └── install.sh
├── qarvix-tools/        ← Phase 2 (Rust workspace)
│   ├── Cargo.toml
│   ├── qarvix-ctl/
│   ├── qarvix-install/
│   └── qarvix-welcome/
└── docs/
```

## License

MIT
