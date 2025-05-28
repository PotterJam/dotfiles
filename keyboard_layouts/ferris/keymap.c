#include QMK_KEYBOARD_H
#if __has_include("keymap.h")
#    include "keymap.h"
#endif

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT_split_3x5_2(KC_B, KC_L, KC_D, KC_C, KC_V, KC_J, KC_Y, KC_O, KC_U, KC_COMM,
        LSFT_T(KC_N), LGUI_T(KC_R), LALT_T(KC_T), LCTL_T(KC_S), KC_G, KC_P, LCTL_T(KC_H), LALT_T(KC_A), LGUI_T(KC_E), LSFT_T(KC_I), KC_X, KC_Q, KC_M, KC_W, KC_Z, KC_K, KC_F, KC_QUOT, KC_UNDS, KC_DOT, LT(1,KC_BSPC), OSM(MOD_LSFT), LT(3,KC_SPC), LT(2,KC_ENT)),
    [1] = LAYOUT_split_3x5_2(KC_ESC, OSM(MOD_LCTL), KC_TRNS, KC_C, KC_V, KC_HOME, KC_CIRC, KC_UP, KC_DLR, KC_ESC,
        OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_ENT, KC_END, KC_LEFT, KC_DOWN, KC_RGHT, KC_DEL, KC_TRNS, KC_LGUI, KC_LALT, KC_TRNS, LGUI(KC_Z), KC_BSLS, KC_TAB, CW_TOGG, KC_PGUP, KC_PGDN, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),
    [2] = LAYOUT_split_3x5_2(
        KC_LCBR, KC_DQUO, KC_PAST, KC_LPRN, KC_RCBR, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
        KC_SCLN, KC_PMNS, KC_COLN, KC_PEQL, KC_AMPR, KC_TRNS, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT),
        KC_QUES, KC_PIPE, KC_PPLS, KC_PSLS, KC_TILD, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_RPRN, KC_EXLM, KC_TRNS, KC_TRNS),
    [3] = LAYOUT_split_3x5_2(KC_LBRC, KC_7, KC_8, KC_9, KC_RBRC, KC_F6, KC_F9, KC_F10, KC_F11, KC_F12, KC_HASH, KC_4, KC_5, KC_6, KC_AT, KC_F7, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT),
    KC_GRV, KC_1, KC_2, KC_3, KC_PERC, KC_F8, KC_F2, KC_F3, KC_F4, KC_F5, KC_0, KC_DOT, KC_TRNS, KC_TRNS)
};

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case LSFT_T(KC_N): 
        case LGUI_T(KC_R): 
        case LALT_T(KC_T): 
        case LCTL_T(KC_S): 
        case LCTL_T(KC_H): 
        case LALT_T(KC_A): 
        case LGUI_T(KC_E): 
        case LSFT_T(KC_I):
        case LT(3,KC_SPC): 
        case LT(1,KC_BSPC):
        case LT(2,KC_ENT):
            // Immediately select the hold action when another key is tapped.
            return true;
        default:
            // Do not select the hold action when another key is tapped.
            return false;
    }
}

bool is_flow_tap_key(uint16_t keycode) {
    if ((get_mods() & (MOD_MASK_CG | MOD_BIT_LALT)) != 0) {
        return false; // Disable Flow Tap on hotkeys.
    }
    switch (get_tap_keycode(keycode)) {
        case KC_SPC:
        case KC_A ... KC_Z:
        case KC_DOT:
        case KC_COMM:
        case KC_UNDS:
        case KC_QUOT:
            return true;
    }
    return false;
}

uint16_t get_flow_tap_term(uint16_t keycode, keyrecord_t* record, 
                           uint16_t prev_keycode) {
    if (is_flow_tap_key(keycode) && is_flow_tap_key(prev_keycode)) {
        switch (keycode) {
            case LT(3,KC_SPC):
              return 0;  // Don't want space layer tap to be affected

            default:
              return FLOW_TAP_TERM;  // Longer timeout otherwise.
        }
    }
    return 0;  // Disable Flow Tap.
}

enum combo_events {
  BK_THIN_ARROW,
  FW_ARROW,
  FW_THIN_ARROW,
  GT_EQ,
  LT_EQ,
  XQ_CW
};

const uint16_t PROGMEM bw_thin_arrow_combo[] = {KC_SCLN, KC_PMNS, COMBO_END};
const uint16_t PROGMEM fw_arrow_combo[] = {KC_PEQL, KC_AMPR, COMBO_END};
const uint16_t PROGMEM fw_thin_arrow_combo[] = {KC_QUES, KC_PIPE, COMBO_END};
const uint16_t PROGMEM gt_eq_combo[] = {KC_PIPE, KC_PPLS, COMBO_END};
const uint16_t PROGMEM lt_eq_combo[] = {KC_DQUO, KC_PAST, COMBO_END};
const uint16_t PROGMEM xq_combo[] = {KC_X, KC_Q, COMBO_END};

combo_t key_combos[] = {
  [BK_THIN_ARROW] = COMBO_ACTION(bw_thin_arrow_combo),
  [FW_ARROW] = COMBO_ACTION(fw_arrow_combo),
  [FW_THIN_ARROW] = COMBO_ACTION(fw_thin_arrow_combo),
  [GT_EQ] = COMBO_ACTION(gt_eq_combo),
  [LT_EQ] = COMBO_ACTION(lt_eq_combo),
  [XQ_CW] = COMBO(xq_combo, CW_TOGG),
};

void process_combo_event(uint16_t combo_index, bool pressed) {
  switch(combo_index) {
    case BK_THIN_ARROW:
      if (pressed) {
        SEND_STRING("<-");
      }
      break;
    case FW_ARROW:
      if (pressed) {
        SEND_STRING("=>");
      }
      break;
    case FW_THIN_ARROW:
      if (pressed) {
        SEND_STRING("->");
      }
      break;
    case GT_EQ:
      if (pressed) {
        SEND_STRING(">=");
      }
      break;
    case LT_EQ:
      if (pressed) {
        SEND_STRING("<=");
      }
      break;
  }
}

#ifdef OTHER_KEYMAP_C
#    include OTHER_KEYMAP_C
#endif // OTHER_KEYMAP_C

