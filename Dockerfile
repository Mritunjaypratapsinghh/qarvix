# Qarvix ISO Build Environment
FROM voidlinux/voidlinux:latest

# Fix stale SSL certs, update repos, install build deps
RUN mkdir -p /etc/xbps.d && \
    echo "repository=https://repo-default.voidlinux.org/current" > /etc/xbps.d/00-repository-main.conf && \
    xbps-install -SMyu -y xbps ca-certificates || true && \
    xbps-install -Syu -y && \
    xbps-install -y \
    xorriso squashfs-tools grub-x86_64-efi grub \
    curl git bash gcc make pkg-config \
    && rm -rf /var/cache/xbps

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /qarvix
COPY . .

# Build Rust tools
RUN cd qarvix-tools && cargo build --release && \
    cp target/release/qarvix-ctl /usr/local/bin/ && \
    cp target/release/qarvix-dev /usr/local/bin/

# Build ISO
CMD ["bash", "build/build-iso.sh"]
