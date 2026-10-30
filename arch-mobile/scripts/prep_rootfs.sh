#!/bin/sh

ARCH_TARBALL="ArchLinuxARM-aarch64-latest.tar.gz"
URL="http://archlinuxarm.org/os/$ARCH_TARBALL"

echo "=========================================="
echo "    ARCH-MOBILE: RAM-Rootfs Packer        "
echo "=========================================="

mkdir -p ../payloads

if [ ! -f "../payloads/$ARCH_TARBALL" ]; then
    echo "[DOWNLOAD] Fetching Arch Linux ARM tarball..."
    if command -v wget >/dev/null 2>&1; then
        wget "$URL" -O "../payloads/$ARCH_TARBALL"
    elif command -v curl >/dev/null 2>&1; then
        curl -L "$URL" -o "../payloads/$ARCH_TARBALL"
    else
        echo "[ERROR] Neither wget nor curl found. Please download manually into payloads/"
        exit 1
    fi
else
    echo "[OK] Arch Linux ARM tarball already exists in payloads/"
fi

echo "=========================================="
echo "[READY] Rootfs ready to be packed into initramfs for 12GB RAM execution."
echo "=========================================="
