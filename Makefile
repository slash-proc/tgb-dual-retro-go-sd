# TGB Dual (Game Boy / Game Boy Color) — standalone Retro-Go SD core.
#
#   make                  — build + pack → tgbdual.bin
#   make host             — Linux/macOS SDL binary (same sources)
#   make host HOST_SDL=3  — same with SDL3
#   make docker           — same build inside Docker (no host toolchain)
#   make docker_shell     — interactive shell in the builder image
#
# One core binary, two launcher tabs: Game Boy (dirname=gb) and Game Boy
# Color (dirname=gbc). Hot engine objects live in ITCM (see ld/tgbdual_core.ld);
# WRAM/VRAM/SRAM use DTCM at runtime. Verbose compiler lines: make V=
#
# BUILD_DIR must stay `build`: ld/tgbdual_core.ld names objects as build/*.o.

#######################################
# Project identity
#######################################
PROJECT_KIND ?= core

CORE_NAME  := tgbdual
CORE_ENTRY := app_main_gb_tgbdual

CORE_TGBDUAL := external/tgbdual-go/gb_core
CORE_PORTING := src/porting

CORE_CXX_SOURCES := \
$(CORE_TGBDUAL)/tgbdual_apu.cpp \
$(CORE_TGBDUAL)/tgbdual_cheat.cpp \
$(CORE_TGBDUAL)/tgbdual_cpu.cpp \
$(CORE_TGBDUAL)/tgbdual_gb.cpp \
$(CORE_TGBDUAL)/tgbdual_lcd.cpp \
$(CORE_PORTING)/tgbdual_mbc_gnw.cpp \
$(CORE_PORTING)/tgbdual_rom_gnw.cpp \
$(CORE_TGBDUAL)/tgbdual_sgb.cpp \
$(CORE_PORTING)/gw_renderer.cpp \
$(CORE_PORTING)/main_gb_tgbdual.cpp

# Soft scaling uses firmware ABI imlib_draw_image (device). Host still
# links src/bilinear.c (see host/Makefile.host).
CORE_C_SOURCES := \
$(CORE_PORTING)/gb_i18n.c

CORE_C_INCLUDES := \
-I$(CORE_TGBDUAL) \
-Iexternal/tgbdual-go \
-I$(CORE_PORTING)

# Relative path so Docker bind-mounts work (do NOT use $(abspath)).
GNW_CORE_SDK ?= sdk
# Must match EXCLUDE_FILE / .core_itcm paths in ld/tgbdual_core.ld.
BUILD_DIR ?= build

#######################################
# Kind-specific compile defs + packing
#######################################
ifeq ($(PROJECT_KIND),core)
# COVERFLOW=1 CHEAT_CODES=1 MAX_CHEAT_CODES=13: match firmware
# retro_emulator_file_t layout (cheat fields after coverflow fields).
CORE_C_DEFS := \
-DPROJECT_KIND_CORE=1 \
-DTARGET_GNW \
-DCOVERFLOW=1 \
-DCHEAT_CODES=1 \
-DMAX_CHEAT_CODES=13

PACKED_BIN   := tgbdual.bin
PAD_LOGO     := src/assets/pad.bmp
HEADER_GB    := src/assets/header_gb.bmp
HEADER_GBC   := src/assets/header_gbc.bmp

CORE_LDSCRIPT := ld/tgbdual_core.ld
CORE_EXTRA_SEGMENTS := itcm:core_itcm

else
$(error PROJECT_KIND must be 'core' (got '$(PROJECT_KIND)'))
endif

include $(GNW_CORE_SDK)/Makefile

PACK_CORE := $(GNW_CORE_SDK)/tools/pack_core.py

#######################################
# Packed header version
#######################################
CORE_VERSION ?= $(shell git describe --tags --dirty 2>/dev/null || echo NOTAG)

#######################################
# Pack
#######################################
.PHONY: pack

pack: $(TARGET_BIN) $(BUILD_DIR)/$(CORE_NAME)_core_itcm.bin $(PAD_LOGO) $(HEADER_GB) $(HEADER_GBC)
	$(V)$(ECHO) [ PACK CORE ] $(PACKED_BIN) version=$(CORE_VERSION)
	$(V)python3 $(PACK_CORE) \
		--elf $(TARGET_ELF) --bin $(TARGET_BIN) \
		--system name="Game Boy",dirname=gb,pad_logo=$(PAD_LOGO),header_logo=$(HEADER_GB),ext=gb,parse=rom,cheat_ext=ggcodes \
		--system name="Game Boy Color",dirname=gbc,pad_logo=$(PAD_LOGO),header_logo=$(HEADER_GBC),ext=gbc,parse=rom,cheat_ext=ggcodes \
		--logo-invert \
		--segment itcm:__ITCM_CORE_START__:__CORE_ITCM_CODE_END__:__CORE_ITCM_BSS_END__:$(BUILD_DIR)/$(CORE_NAME)_core_itcm.bin \
		--core-name "TGB Dual" \
		--version "$(CORE_VERSION)" \
		--out $(PACKED_BIN)

all: pack

# Read-only helpers for CI / scripts (make print-PROJECT_KIND, etc.).
.PHONY: print-PROJECT_KIND print-PACKED_BIN print-CORE_NAME print-DOCKER_IMAGE \
	print-TARGET_ELF print-TARGET_MAP print-CORE_VERSION
print-PROJECT_KIND:
	@echo $(PROJECT_KIND)
print-PACKED_BIN:
	@echo $(PACKED_BIN)
print-CORE_NAME:
	@echo $(CORE_NAME)
print-DOCKER_IMAGE:
	@echo $(DOCKER_IMAGE)
print-TARGET_ELF:
	@echo $(TARGET_ELF)
print-TARGET_MAP:
	@echo $(BUILD_DIR)/$(CORE_NAME)_core.map
print-CORE_VERSION:
	@echo $(CORE_VERSION)

clean::
	$(V)rm -f $(PACKED_BIN)

#######################################
# Docker (same image as firmware repo)
#######################################
.PHONY: docker docker_pull docker_shell

RELEASE_VERSION ?= v1.5
DOCKER_REPOSITORY ?= sylverb/retro-go-sd-builder
DOCKER_IMAGE ?= $(DOCKER_REPOSITORY):$(RELEASE_VERSION)

DOCKER_TTY_FLAG := $(shell if [ -t 0 ]; then echo -it; else echo; fi)
DOCKER_USER := $(shell id -u):$(shell id -g)
DOCKER_RUN := docker run --rm $(DOCKER_TTY_FLAG) \
	--user $(DOCKER_USER) \
	-v "$(CURDIR):/opt/workdir" \
	-w /opt/workdir \
	$(DOCKER_IMAGE)

docker:
	$(V)$(ECHO) "[ DOCKER ]" $(DOCKER_IMAGE) "PROJECT_KIND=$(PROJECT_KIND)"
	$(V)$(DOCKER_RUN) make --no-print-directory -j$$(nproc) PROJECT_KIND=$(PROJECT_KIND)

docker_pull:
	$(V)$(ECHO) "[ PULL ]" $(DOCKER_IMAGE)
	$(V)docker pull $(DOCKER_IMAGE)

docker_shell:
	$(DOCKER_RUN) bash

#######################################
# Host SDL (Linux / macOS)
#######################################
include host/Makefile.host
