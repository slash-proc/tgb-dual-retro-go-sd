# Changelog

## [v0.0.2]

### Added

- Nothing.

### Changed

- SDK update (Prefer DTCM for WRAM / VRAM / cart SRAM)

### Fixed

- Power-off wake crash: entry used `uint8_t save_slot`, so OFF slot `-1`
  became `255` and panicked in `odroid_system_emu_load_state`
- Removed workaround for green flashing screen as issue has been fixed in firmware

### Install

**Core**

- Download `tgbdual-vx.x.x.zip` from the GitHub release and unzip it onto the
  SD card root (it places `cores/tgbdual.bin`).
- Put ROMs under `/roms/gb/` (`.gb`) and `/roms/gbc/` (`.gbc`).
- Optional cheats: `.ggcodes` in /cheats/gb or /cheats/gbc.
- Requires firmware whose ABI matches `SDK_VERSION` in this repository.
