/*
 * Desktop entry: init SDL, then jump into the same CORE_ENTRY as on device.
 *
 * Usage:
 *   ./tgbdual_host [options] [rom]
 *   ./tgbdual_host --system gbc game.gb
 *
 * Options:
 *   --system gb|gbc|sgb   Console mode (also HOST_SYSTEM=gb|gbc|sgb)
 *   -h, --help
 *
 * ROM path: argv, or HOST_ROM.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "host_compat.h"
#include "host_platform.h"
#include "odroid_settings.h"

#ifndef HOST_SCALE
#define HOST_SCALE 2
#endif

/* Match tgbdual_sgb.h GB_CONSOLE_* (avoid pulling C++ headers here). */
#define HOST_CONSOLE_DMG 1
#define HOST_CONSOLE_CGB 2
#define HOST_CONSOLE_SGB 3

/* Projects may use a custom CORE_ENTRY (e.g. app_main_gb_tgbdual);
 * Makefile.host passes -DHOST_APP_MAIN=$(CORE_ENTRY). */
#ifndef HOST_APP_MAIN
#define HOST_APP_MAIN app_main
#endif

#ifdef __cplusplus
extern "C"
#endif
void HOST_APP_MAIN(uint8_t load_state, uint8_t start_paused, int8_t save_slot);

static void usage(const char *argv0)
{
    fprintf(stderr,
            "Usage: %s [options] [rom.gb|.gbc]\n"
            "\n"
            "Options:\n"
            "  --system gb|gbc|sgb   Console mode (default: from cart header)\n"
            "  -h, --help            Show this help\n"
            "\n"
            "Env:\n"
            "  HOST_ROM=path         ROM if not passed on the command line\n"
            "  HOST_SYSTEM=gb|gbc|sgb  Same as --system\n",
            argv0);
}

static int parse_system(const char *s, int *out)
{
    if (!s || !out)
        return -1;
    if (!strcasecmp(s, "gb") || !strcasecmp(s, "dmg")) {
        *out = HOST_CONSOLE_DMG;
        return 0;
    }
    if (!strcasecmp(s, "gbc") || !strcasecmp(s, "cgb")) {
        *out = HOST_CONSOLE_CGB;
        return 0;
    }
    if (!strcasecmp(s, "sgb")) {
        *out = HOST_CONSOLE_SGB;
        return 0;
    }
    return -1;
}

static const char *system_name(int mode)
{
    switch (mode) {
    case HOST_CONSOLE_CGB: return "GBC";
    case HOST_CONSOLE_SGB: return "SGB";
    default:               return "GB";
    }
}

int main(int argc, char **argv)
{
    const char *title = "TGB Dual (host)";
    const char *rom = getenv("HOST_ROM");
    const char *sys_env = getenv("HOST_SYSTEM");
    int system_mode = -1;
    int i;

    if (sys_env && parse_system(sys_env, &system_mode) != 0) {
        fprintf(stderr, "host: invalid HOST_SYSTEM=%s (want gb|gbc|sgb)\n", sys_env);
        return 1;
    }

    for (i = 1; i < argc; i++) {
        const char *a = argv[i];
        if (!a || !a[0])
            continue;
        if (!strcmp(a, "-h") || !strcmp(a, "--help")) {
            usage(argv[0]);
            return 0;
        }
        if (!strcmp(a, "--system") || !strcmp(a, "-s")) {
            if (i + 1 >= argc) {
                fprintf(stderr, "host: %s needs gb|gbc|sgb\n", a);
                return 1;
            }
            if (parse_system(argv[++i], &system_mode) != 0) {
                fprintf(stderr, "host: invalid system '%s' (want gb|gbc|sgb)\n", argv[i]);
                return 1;
            }
            continue;
        }
        if (!strncmp(a, "--system=", 9)) {
            if (parse_system(a + 9, &system_mode) != 0) {
                fprintf(stderr, "host: invalid --system= (want gb|gbc|sgb)\n");
                return 1;
            }
            continue;
        }
        if (a[0] == '-') {
            fprintf(stderr, "host: unknown option '%s'\n", a);
            usage(argv[0]);
            return 1;
        }
        /* First non-option argument = ROM path. */
        rom = a;
    }

    if (host_platform_init(title, HOST_SCALE) != 0)
        return 1;

    gw_core_bridge_init();
    if (rom)
        host_set_rom_path(rom);

    if (system_mode >= 0) {
        odroid_settings_app_int32_set("GBSystem", system_mode);
        printf("host: system %s\n", system_name(system_mode));
    }

    printf("host: Esc or close window to quit\n");
    printf("host: Arrows=D-pad  Z=B  X=A  Enter=Start  Shift=Select  A/S=Y/X\n");
    printf("host: F1=save state  F2=load state  (./host_saves/)\n");
    if (rom)
        printf("host: ROM %s\n", rom);

    HOST_APP_MAIN(0, 0, 0);

    host_platform_shutdown();
    return 0;
}
