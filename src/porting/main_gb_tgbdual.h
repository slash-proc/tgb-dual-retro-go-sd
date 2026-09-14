#pragma once

extern bool tgb_drawFrame;
void app_main_gb_tgbdual(uint8_t load_state, uint8_t start_paused, int8_t save_slot);
#if CHEAT_CODES == 1
void update_cheats_gb();
#endif