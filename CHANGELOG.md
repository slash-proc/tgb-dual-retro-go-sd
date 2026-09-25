# Changelog

## [v0.0.3]

### Added

- Optional boot ROMs from `/bios/gb/gb_bios.bin` (256 B) and
  `/bios/gb/gbc_bios.bin` (2304 B). When present, the Nintendo boot
  sequence runs instead of the post-boot skip.
- System menu: GB games can switch to **GBC** when `gbc_bios.bin` is present
- System menu / host: CGB-compatible (not CGB-only) games can force **GB**
- Host: `--system gb|gbc|sgb` / `HOST_SYSTEM` to force console mode

### Changed

- SDK update (Prefer DTCM for WRAM / VRAM / cart SRAM)

### Fixed

- Power-off wake crash: entry used `uint8_t save_slot`, so OFF slot `-1`
  became `255` and panicked in `odroid_system_emu_load_state`
- Removed workaround for green flashing screen as issue has been fixed in firmware
- DMG games on GBC: honor KEY0 DMG-compat (BGP/OBP + ignore attr map) so
  boot-ROM colorization (e.g. Link's Awakening) looks correct

### Install

**Core**

- Download `tgbdual-vx.x.x.zip` from the GitHub release and unzip it onto the
  SD card root (it places `cores/tgbdual.bin`).
- Put ROMs under `/roms/gb/` (`.gb`) and `/roms/gbc/` (`.gbc`).
- Optional boot ROMs: `/bios/gb/gb_bios.bin`, `/bios/gb/gbc_bios.bin`.
- Optional cheats: `.ggcodes` in /cheats/gb or /cheats/gbc.
- Requires firmware whose ABI matches `SDK_VERSION` in this repository.
