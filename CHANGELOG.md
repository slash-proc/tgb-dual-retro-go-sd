# Changelog

## [v0.1.1] - 2026-09-09

### Changed

- The manifest's `kind` is now `core`, not `emulator`. A core that emulates
  nothing -- Doom -- showed that the old word named a subset rather than the
  set, so the spec took the general term and the SDK and the spec now agree.
  The previous release publishes the old value and no longer validates.

## [v0.1.0] - 2026-09-08

### Added

- Published under the [GWRG distribution
  spec](https://github.com/slash-proc/gwrg-dist-spec): a `manifest.json`
  describing this core and the two systems it provides, an offline bundle, and
  a GitHub Pages mirror of `dist/` that a web installer can read without a
  human in the loop.
- `symbols[]` publishes the linked ELF so a crash address from a device can be
  resolved back to a function. It is named by the manifest and mirrored, but is
  not part of the install set and never reaches the card.
- `gwrg.json`, the hand-written half of the manifest: the short console name
  for each system and whether compressed ROMs work. Everything else -- the
  systems, their folders, extensions and browse mode, the firmware ABI, sizes
  and hashes -- is derived from the packed binary at release time, so the
  manifest and the firmware cannot disagree about which folder a system reads.
- Game Boy and Game Boy Color are declared as two systems from one binary,
  keyed by the `gb` and `gbc` folders the packed core names. Neither needs a
  BIOS, so neither declares one.

### Changed

- `scripts/make_manifest.py`, `build_dist.py`, `make_bundle.py` and
  `stage_release.py` are now the shared copies, byte-identical across every
  project. A script that has to be edited on the way in is a script that
  drifts.
- The Makefile answers `print-SIDECARS` and `print-RO_BIN`. This core installs
  neither, but the shared release script reads its variables positionally: a
  missing target shifts every later value onto the wrong name.


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
