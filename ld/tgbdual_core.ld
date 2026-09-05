/*
 * TGB Dual (Game Boy / Game Boy Color) — custom linker script.
 *
 * Hot emulator engine objects run from ITCM (zero-wait I-fetch). Data that
 * used to live in ITCM (WRAM / VRAM / cart SRAM) is allocated at runtime from
 * DTCM / RAM_EMU instead — see gw_core_cxx_support.cpp and tgbdual_rom.cpp.
 *
 * BUILD_DIR must stay `build`: EXCLUDE_FILE / .core_itcm paths below name
 * objects as build/*.o (same constraint as ld/pce_core.ld).
 *
 * main_gb_tgbdual.o, gw_renderer.o, tgbdual_rom/cheat, bilinear, and the
 * ABI bridge stay in RAM_EMU (entry trampoline + launcher-facing code).
 */

INCLUDE gnw_ram_emu.ld
INCLUDE gnw_itcm_core.ld

MEMORY
{
  RAM_EMU (xrw) : ORIGIN = __RAM_EMU_START__, LENGTH = __RAM_EMU_LENGTH__
  ITCM    (xrw) : ORIGIN = __ITCM_CORE_START__, LENGTH = __ITCM_CORE_LENGTH__
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* PF_R | PF_X */
  data PT_LOAD FLAGS(6); /* PF_R | PF_W */
  itcm PT_LOAD FLAGS(5);
}

SECTIONS
{
  /* Segment 0: RAM_EMU — entry, porting, bridge; hot .text excluded below. */
  .core_entry __RAM_EMU_START__ :
  {
    KEEP(*(.core_entry))
    KEEP(*(.gw_core_bridge_probe))
    . = ALIGN(4);
    EXCLUDE_FILE(
      build/tgbdual_cpu.o
      build/tgbdual_lcd.o
      build/tgbdual_mbc_gnw.o
      build/tgbdual_apu.o
      build/tgbdual_gb.o
      build/tgbdual_sgb.o
    ) *(.text*)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)

    . = ALIGN(4);
    __CORE_INIT_ARRAY_START__ = .;
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    __CORE_INIT_ARRAY_END__ = .;
  } >RAM_EMU :text

  .data :
  {
    *(.data*)
  } >RAM_EMU :data

  __CORE_CODE_END__ = .;

  .bss (NOLOAD) :
  {
    . = ALIGN(8);
    *(.bss*)
    *(COMMON)
    . = ALIGN(8);
  } >RAM_EMU :data

  __CORE_BSS_END__ = .;

  ASSERT(__CORE_BSS_END__ <= __RAM_EMU_END__,
         "Error: tgbdual RAM_EMU segment (code+data+bss) overflows RAM_EMU")

  /* Segment 1: ITCM — CPU / PPU / MBC / APU / SGB hot code only. */
  .core_itcm __ITCM_CORE_START__ :
  {
    __CORE_ITCM_CODE_START__ = .;
    build/tgbdual_cpu.o(.text*)
    build/tgbdual_lcd.o(.text*)
    build/tgbdual_mbc_gnw.o(.text*)
    build/tgbdual_apu.o(.text*)
    build/tgbdual_gb.o(.text*)
    build/tgbdual_sgb.o(.text*)
    . = ALIGN(4);
    __CORE_ITCM_CODE_END__ = .;
  } >ITCM AT>RAM_EMU :itcm

  /* Hot objects' .data/.bss stay in RAM_EMU above — code-only ITCM segment. */
  __CORE_ITCM_BSS_END__ = __CORE_ITCM_CODE_END__;

  ASSERT(__CORE_ITCM_BSS_END__ <= __ITCM_CORE_START__ + __ITCM_CORE_LENGTH__,
         "Error: tgbdual ITCM segment (code) overflows the 64K ITCM region")

  __exidx_start = .;
  __exidx_end = .;

  /DISCARD/ :
  {
    *(.fini_array*)
    *(.preinit_array*)
    *(.ARM.exidx*)
    *(.ARM.extab*)
    *(.comment)
    *(.ARM.attributes)
  }
}
