# Qarvix ISO Build Environment
FROM voidlinux/voidlinux:latest

# Install build dependencies
RUN xbps-install -Syu -y && \
    xbps-install -y \
    xorriso \
    squashfs-tools \
    grub-x86_64-efi \
    grub-i386-pc \
    curl \
    git \
    bash \
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
