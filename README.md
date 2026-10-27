# Arch-mobile
Arch mobile develepment.

# Moto G84 5G (`bangkk`) - Arch Linux ARM Port

An experimental project to boot and run native **Arch Linux ARM** on the Motorola Moto G84 5G (`bangkk`).

> ⚠️ **Status: In Active Development (Pre-Alpha / Tooling Phase)**  
> This project is currently in the setup and repartitioning planning stage. **Do not attempt** to run these scripts or payloads unless you fully understand the risks of hard-bricking your device.

---

## 📌 Project Overview
The goal of this repository is to replace/bypass the standard Android OS stack on the Moto G84 5G (`bangkk`) and establish a functional, mainlined (or adapted) Arch Linux ARM environment. 

### Key Targets:
- [ ] Establish fastboot communication & automated flashing tooling
- [ ] Safe userdata repartitioning schema for Linux roots (EFI/GPT mapping)
- [ ] Bootloader / EDK2 UEFI porting & bootloader entry validation
- [ ] Kernel compilation with essential device tree entries (`dtb`)
- [ ] Base system installation (Arch Linux ARM rootfs)
- [ ] Display (DRM/KMS), touch input, and hardware connectivity testing

---

## 🚦 Current Progress
- **Phase 1: Environment & Tooling** (In Progress)
  - [x] Workspace & development environment setup
  - [x] Initial repository setup and open-source licensing (GPLv3)
  - [ ] Device detection via `fastboot` and partition table dump

---

## 📜 License
This project is licensed under the **GNU General Public License v3.0** (GPLv3). See the `LICENSE` file for details. Copyright (C) 2026 mcminny_gg.
