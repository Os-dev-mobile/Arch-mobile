#!/bin/sh

echo "[INFO] Checking for connected fastboot devices..."

# Capture the output of fastboot devices
DEVICE_OUTPUT=$(fastboot devices)

# Check if the output is empty
if [ -z "$DEVICE_OUTPUT" ]; then
    echo "[ERROR] No fastboot device detected!"
    echo "Make sure the phone is plugged in and showing the Fastboot screen."
    exit 1
fi

echo "[SUCCESS] Device detected:"
echo "$DEVICE_OUTPUT"
exit 0
