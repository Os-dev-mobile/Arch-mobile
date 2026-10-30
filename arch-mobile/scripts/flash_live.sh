#!/bin/sh

echo "=========================================="
echo "   ARCH-MOBILE: Kernel Panic Test Boot    "
echo "=========================================="

# 1. Verify fastboot is available
if ! command -v fastboot >/dev/null 2>&1; then
    echo "[ERROR] 'fastboot' command not found on host PC."
    exit 1
fi

# 2. Verify device is connected in fastboot mode
DEVICE_ID=$(fastboot devices | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
    echo "[ERROR] No device detected in fastboot mode!"
    echo "Boot your Moto G84 into fastboot mode and connect via USB."
    exit 1
fi

echo "[OK] Fastboot device detected: $DEVICE_ID"

# Define directories & paths
PAYLOADS_DIR="./payloads/boot"
BACKUPS_DIR="./backups"
TOOLS_DIR="./tools"
INITRAMFS_IMG="$PAYLOADS_DIR/initramfs-linux.img.lz4"
STOCK_BOOT="$BACKUPS_DIR/boot.img"
OUTPUT_IMG="./payloads/boot.img"
UNPACK_TOOL="$TOOLS_DIR/unpack_bootimg.py"

# Validate essential files
if [ ! -f "$INITRAMFS_IMG" ]; then
    echo "[ERROR] LZ4-compressed Arch initramfs image not found at $INITRAMFS_IMG!"
    echo "Run lz4 compression on your initramfs-linux.img first."
    exit 1
fi

if [ ! -f "$STOCK_BOOT" ]; then
    echo "[ERROR] Missing $STOCK_BOOT! Run ./scripts/backup_lineageos.sh first."
    exit 1
fi

# 3. Ensure tools directory exists and fetch unpack_bootimg.py if missing
mkdir -p "$TOOLS_DIR"
if [ ! -f "$UNPACK_TOOL" ]; then
    echo "[INFO] Downloading official Android unpack_bootimg.py tool..."
    curl -sSL "https://android.googlesource.com/platform/system/tools/mkbootimg/+/${ANDROID_BUILD_REVISION:-master}/unpack_bootimg.py?format=TEXT" | base64 -d > "$UNPACK_TOOL"
    if [ ! -s "$UNPACK_TOOL" ]; then
        curl -sSL "https://raw.githubusercontent.com/jbeich/platform_system_tools_mkbootimg/master/unpack_bootimg.py" -o "$UNPACK_TOOL"
    fi
    chmod +x "$UNPACK_TOOL"
fi

# 4. Unpack stock boot.img to extract the clean LineageOS kernel blob
UNPACK_BOOT_OUT="$PAYLOADS_DIR/unpacked_boot"
mkdir -p "$UNPACK_BOOT_OUT"

echo "[UNPACKING] Extracting LineageOS kernel from $STOCK_BOOT..."
python3 "$UNPACK_TOOL" --boot_img "$STOCK_BOOT" --out "$UNPACK_BOOT_OUT"

KERNEL_IMG="$UNPACK_BOOT_OUT/kernel"
if [ ! -f "$KERNEL_IMG" ]; then
    echo "[ERROR] LineageOS kernel blob not found after unpacking!"
    exit 1
fi

# 5. Pack Header Version 3 Boot Image with panic=5 using LZ4 ramdisk
echo "[PACKING] Generating Header v3 image with LZ4 ramdisk..."
mkbootimg \
    --header_version 3 \
    --kernel "$KERNEL_IMG" \
    --ramdisk "$INITRAMFS_IMG" \
    --cmdline "console=ttyMSM0,115200n8 earlycon=msm_serial_dm,0xa900000 androidboot.hardware=qcom audit=0 panic=5" \
    -o "$OUTPUT_IMG"

if [ $? -ne 0 ]; then
    echo "[ERROR] mkbootimg failed!"
    exit 1
fi

echo "[SAFETY] Package built. Initiating volatile RAM boot..."

# 6. Volatile Boot Handoff
fastboot boot "$OUTPUT_IMG"

if [ $? -eq 0 ]; then
    echo "[SUCCESS] Fastboot boot command sent!"
else
    echo "[ERROR] Fastboot boot handoff failed."
    exit 1
fi
