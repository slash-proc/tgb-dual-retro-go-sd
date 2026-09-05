# TGB Dual — Retro-Go SD Core

Standalone **Game Boy / Game Boy Color** dynamic core for
[Game & Watch Retro-Go SD](https://github.com/sylverb/game-and-watch-retro-go-sd),
based on [tgbdual-go](https://github.com/sylverb/tgbdual-go) (`sd` branch).

One freestanding Cortex-M7 binary talks to the launcher **only** through
`gw_firmware_abi_t`. Packaged as `/cores/tgbdual.bin` with two system tabs
(`gb` + `gbc`).

Memory layout:

- **ITCM** — hot engine code (`cpu` / `lcd` / `mbc` / `apu` / `gb` / `sgb`)
- **DTCM** — WRAM, VRAM, cart SRAM (no longer parked in ITCM)
- **RAM_EMU** — porting layer, APU filter BSS, ROM image / flash cache

## Requirements

**Local build**

- `arm-none-eabi-gcc` (hard-float `fpv5-d16`)
- GNU Make
- Python 3 + Pillow (`pip install -r requirements.txt`)
- Git submodule: `git submodule update --init --recursive`

**Host SDL preview** (optional)

- Native C/C++ compiler, pkg-config, SDL2 or SDL3

**Docker**

- Image [`sylverb/retro-go-sd-builder`](https://hub.docker.com/r/sylverb/retro-go-sd-builder)
  (default tag `v1.5`)

## Quick start

```bash
git submodule update --init --recursive
make                 # → tgbdual.bin
make docker          # same inside the builder image
make host            # → ./tgbdual_host
./tgbdual_host /path/to/game.gb
```

Install on the SD card:

- `/cores/tgbdual.bin`
- ROMs under `/roms/gb/` (`.gb`) and `/roms/gbc/` (`.gbc`)
- Optional Game Genie/Shark: `.ggcodes` next to the ROM

## Host controls

Arrows = D-pad, `Z`/`X` = B/A, Enter = Start, Shift = Select,
`A`/`S` = Y/X. `F1` / `F2` = save / load state (`./host_saves/`).

On macOS, if `pkg-config sdl2` fails:

```bash
export PKG_CONFIG_PATH="$(brew --prefix)/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
```

## Build notes

- Logos use `--logo-invert` (icons are light-on-dark BMPs).
- `BUILD_DIR` must stay `build` (linker script lists `build/*.o` for ITCM).
- ABI sync from firmware: `./scripts/sync_from_firmware.sh <firmware-tree>`

## License

See `LICENSE` and the headers in `external/tgbdual-go/` / `src/porting/`.
