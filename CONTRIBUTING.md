# Contributing to Qarvix

Thanks for your interest in contributing to Qarvix! ⚡

## How to Contribute

### Reporting Bugs
- Open an [issue](https://github.com/Mritunjaypratapsinghh/qarvix/issues)
- Include: hardware info, steps to reproduce, expected vs actual behavior

### Suggesting Features
- Open an issue with the `enhancement` label
- Describe the use case and proposed solution

### Code Contributions

1. Fork the repo
2. Create a branch: `git checkout -b feat/my-feature`
3. Make changes
4. Test locally
5. Commit: `git commit -m "feat: description"`
6. Push: `git push origin feat/my-feature`
7. Open a Pull Request

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: fix a bug
docs: documentation changes
style: formatting, no code change
refactor: code restructuring
test: adding tests
chore: maintenance tasks
```

### Code Standards

- **Rust**: `cargo fmt` + `cargo clippy` must pass
- **Shell**: `shellcheck` compliant
- **Configs**: consistent with Tokyo Night theme (#1a1b26 bg, #7aa2f7 accent)

### Project Structure

```
qarvix/
├── build/           # ISO build scripts (Bash)
├── config/          # System configs
├── packages/        # Package lists
├── branding/        # Visual identity
├── installer/       # Disk installer
├── qarvix-tools/    # Rust workspace
│   ├── qarvix-ctl/  # System control CLI
│   └── qarvix-dev/  # Dev environment manager
└── docs/            # Documentation
```

### Development Setup

```bash
# Clone
git clone https://github.com/Mritunjaypratapsinghh/qarvix.git
cd qarvix

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build tools
cd qarvix-tools && cargo build

# Run checks
cargo fmt --all -- --check
cargo clippy --all-targets
```

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
