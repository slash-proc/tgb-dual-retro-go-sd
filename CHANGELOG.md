# Changelog

## [v0.0.1]

### Added

- ITCM placement for hot engine code (`cpu` / `lcd` / `mbc` / `apu` / `gb` / `sgb`)

### Changed

- Prefer DTCM for WRAM / VRAM / cart SRAM (ITCM reserved for code)

### Install

**Core**

- Download `tgbdual-v0.0.1.zip` from the GitHub release and unzip it onto the
  SD card root (it places `cores/tgbdual.bin`).
- Put ROMs under `/roms/gb/` (`.gb`) and `/roms/gbc/` (`.gbc`).
- Optional cheats: `.ggcodes` in /cheats/gb or /cheats/gbc.
- Requires firmware whose ABI matches `SDK_VERSION` in this repository.
