The files available are not functional yet





Arch-Mobile: Manual Live RAM-Boot Guide for Motorola Moto G84 (bangkk)

    DISCLAIMER: This guide involves unlocking the bootloader, executing manual partition backups, and live RAM-boot injection. This process carries inherent risks, including potential data loss or soft-bricking if performed incorrectly. Neither the author nor contributors are responsible for any damage to your device. Proceed entirely at your own risk.

Tested Environment & Specifications

    Target Device: Motorola Moto G84 5G (bangkk) — combined boot.img partition architecture (no standalone init_boot partition).

    Phone OS (Testing): LineageOS (tested for backup validation; stock backup workflow has also been verified).

    Host Operating System (Laptop/PC): Arch Linux / NixOS (Linux desktop environment with adb and fastboot utilities installed).

Step 1: Enable USB Debugging (Developer Options)
Before running any scripts or connecting your phone to your PC via USB, you must enable Developer Options and USB Debugging on your device:

    Open your phone's Settings.

    Scroll down and tap on About phone.

    Tap on Build number 7 times rapidly until you see a toast notification saying: "You are now a developer!"

    Go back to the main Settings menu and tap on System.

    Select Advanced to find Developer options.

    Scroll down inside Developer options and toggle on USB debugging.

    Connect your phone to your PC via a USB cable and tap Allow when prompted on your phone screen to trust the connected computer.

Step 2: Device State Check & Preparation
Verify that your host machine can communicate with your device via ADB and Fastboot:
adb devices
fastboot devices
Ensure your working directory contains the necessary script structure (scripts/, payloads/, etc.) before initiating the workflow.

Step 3: Run the Backup Script
Execute the partition backup script to securely pull critical device partitions over ADB with dynamic slot detection:
./scripts/backup_lineageos.sh
(Note: Ensure backups complete successfully before proceeding to fastboot interactions).

Step 4: Boot into Fastboot Mode
Reboot your device directly into Fastboot mode to prepare for payload injection:
adb reboot bootloader
Alternatively, you can power off the phone and hold Volume Down + Power simultaneously until the fastboot menu appears on screen.

Step 5: Rootfs & Kernel Payload Placement

    Run the rootfs preparation script to generate or fetch your target root filesystem components:
    ./scripts/prep_rootfs.sh

    Payload Check: Ensure the resulting payloads/ directory (containing your compiled kernel image Image.gz) is correctly placed inside your main arch-mobile/ project folder (move it if generated outside the main directory).

Step 6: Live RAM-Boot Execution (Current Next Step)
With your device in Fastboot mode and the payload properly positioned inside the workspace, execute the live RAM handoff script to inject the Arch-Mobile kernel and rootfs directly into your device's RAM without modifying permanent storage:
./scripts/flash_live.sh

Step 7: Post-Boot Verification & Exiting

    Once the kernel hands off, verify the live environment directly on your device screen.

    To exit Arch-Mobile and instantly restore your normal host OS (LineageOS), simply force a reboot by holding down the Power button (and Volume Down) for 10–15 seconds, or type reboot inside the live terminal. Because this is a pure RAM-boot, the volatile memory clears entirely and your device boots back up normally.
