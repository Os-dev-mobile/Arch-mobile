#!/bin/sh

BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

echo "=========================================="
echo "    ARCH-MOBILE: LineageOS Partition Backup"
echo "=========================================="

# Check if backup files already exist on the host PC
if [ -f "$BACKUP_DIR/boot.img" ] && [ -f "$BACKUP_DIR/vendor_boot.img" ] && [ -f "$BACKUP_DIR/init_boot.img" ]; then
    echo "[INFO] Existing LineageOS backups found in $BACKUP_DIR."
    echo "[SUCCESS] Backup check passed. Skipping ADB pull."
    exit 0
fi

echo "[INFO] Checking ADB connection..."
ADB_OUT=$(adb devices | grep -v "List" | grep -E "device|recovery")

if [ -z "$ADB_OUT" ]; then
    echo "[ERROR] No device detected in ADB mode!"
    echo "Make sure your phone is booted into Recovery mode with USB debugging enabled."
    exit 1
fi

echo "[INFO] Checking device privilege level..."
ADB_STATE=$(adb devices | grep -v "List" | grep "recovery")

if [ -n "$ADB_STATE" ]; then
    echo "[SUCCESS] Recovery mode detected. ADB is running with root privileges."
    TEMP_DIR="/tmp"
    USE_SU=""
else
    if adb shell which su >/dev/null 2>&1; then
        echo "[INFO] Superuser (su) found."
        TEMP_DIR="/data/local/tmp"
        USE_SU="su -c"
    else
        echo "[ERROR] No root privileges and 'su' not found!"
        exit 1
    fi
fi

# Determine active slot
SLOT=$(adb shell getprop ro.boot.slot_suffix 2>/dev/null | tr -d '\r')
if [ -z "$SLOT" ]; then
    SLOT=$(adb shell getprop ro.boot.slot 2>/dev/null | tr -d '\r')
    case "$SLOT" in
        a|b) SLOT="_$SLOT" ;;
        *) SLOT="" ;;
    esac
fi

BOOT_PART="boot$SLOT"
VENDOR_BOOT_PART="vendor_boot$SLOT"
echo "[INFO] Active Partitions -> Boot: $BOOT_PART | Vendor Boot: $VENDOR_BOOT_PART"

# 1. Dump & Pull Boot Partition
if [ ! -f "$BACKUP_DIR/boot.img" ]; then
    echo "[INFO] Dumping $BOOT_PART..."
    if [ -n "$USE_SU" ]; then
        adb shell "$USE_SU 'dd if=/dev/block/by-name/$BOOT_PART of=$TEMP_DIR/boot.img bs=4M status=none'"
    else
        adb shell "dd if=/dev/block/by-name/$BOOT_PART of=$TEMP_DIR/boot.img bs=4M status=none"
    fi
    adb pull "$TEMP_DIR/boot.img" "$BACKUP_DIR/boot.img"
    adb shell rm "$TEMP_DIR/boot.img" 2>/dev/null
fi

# 2. Dump & Pull Vendor Boot Partition (Contains the hardware DTB)
if [ ! -f "$BACKUP_DIR/vendor_boot.img" ]; then
    echo "[INFO] Dumping $VENDOR_BOOT_PART..."
    if [ -n "$USE_SU" ]; then
        adb shell "$USE_SU 'dd if=/dev/block/by-name/$VENDOR_BOOT_PART of=$TEMP_DIR/vendor_boot.img bs=4M status=none'"
    else
        adb shell "dd if=/dev/block/by-name/$VENDOR_BOOT_PART of=$TEMP_DIR/vendor_boot.img bs=4M status=none"
    fi
    adb pull "$TEMP_DIR/vendor_boot.img" "$BACKUP_DIR/vendor_boot.img"
    adb shell rm "$TEMP_DIR/vendor_boot.img" 2>/dev/null
fi

# Handle init_boot compatibility
if [ ! -f "$BACKUP_DIR/init_boot.img" ]; then
    echo "[INFO] Creating init_boot.img copy for script compatibility..."
    cp "$BACKUP_DIR/boot.img" "$BACKUP_DIR/init_boot.img"
fi

# Verify backup files were generated correctly
if [ -s "$BACKUP_DIR/boot.img" ] && [ -s "$BACKUP_DIR/vendor_boot.img" ] && [ -s "$BACKUP_DIR/init_boot.img" ]; then
    echo "[SUCCESS] LineageOS boot and vendor_boot backups saved successfully to $BACKUP_DIR!"
else
    echo "[ERROR] Backup failed or files are empty."
    exit 1
fi

echo "[INFO] Rebooting device into Fastboot mode..."
adb reboot bootloader
exit 0
