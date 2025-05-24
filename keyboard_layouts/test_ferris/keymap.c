#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT_split_3x5_2(KC_B, KC_L, KC_D, KC_C, KC_V, KC_J, KC_Y, KC_O, KC_U, KC_COMM, KC_N, KC_R, KC_T, KC_F, KC_G, KC_P, KC_H, KC_A, KC_E, KC_I, KC_X, KC_Q, KC_M, KC_W, KC_Z, KC_K, KC_F, KC_QUOT, KC_UNDS, KC_DOT, LT(4,KC_BSPC), LT(1,KC_TAB), LT(3,KC_SPC), LT(2,KC_ENT)),
    [1] = LAYOUT_split_3x5_2(KC_ESC, OSM(MOD_LCTL), KC_TAB, KC_C, KC_V, KC_TRNS, KC_HOME, KC_UP, KC_END, KC_ESC, OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_ENT, KC_TRNS, KC_LEFT, KC_DOWN, KC_RGHT, KC_DEL, KC_TRNS, KC_LGUI, KC_LALT, KC_TRNS, LGUI(KC_Z), KC_TRNS, KC_TRNS, CW_TOGG, KC_PGUP, KC_PGDN, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),
    [2] = LAYOUT_split_3x5_2(KC_TILD, KC_LCBR, KC_PAST, KC_RCBR, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_EXLM, KC_PEQL, KC_PPLS, KC_PSLS, KC_PERC, KC_TRNS, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT), KC_LT, KC_PIPE, KC_PMNS, KC_GT, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_COLN, KC_TRNS, KC_TRNS),
    [3] = LAYOUT_split_3x5_2(KC_TRNS, KC_7, KC_8, KC_9, KC_TRNS, KC_F6, KC_F9, KC_F10, KC_F11, KC_F12, KC_DOT, KC_4, KC_5, KC_6, KC_TRNS, KC_F7, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT), KC_TRNS, KC_1, KC_2, KC_3, KC_TRNS, KC_F8, KC_F2, KC_F3, KC_F4, KC_F5, KC_TRNS, KC_0, KC_TRNS, KC_TRNS),
    [4] = LAYOUT_split_3x5_2(KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_CIRC, KC_HASH, KC_DLR, KC_AT, OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_TRNS, KC_GRV, KC_LPRN, KC_DQUO, KC_RPRN, KC_SCLN, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_BSLS, KC_LBRC, KC_AMPR, KC_RBRC, KC_QUES, KC_TRNS, KC_TRNS, KC_UNDS, KC_TRNS)
};

bool is_flow_tap_key(uint16_t keycode) {
    if ((get_mods() & (MOD_MASK_CG | MOD_BIT_LALT)) != 0) {
        return false; // Disable Flow Tap on hotkeys.
    }
    switch (get_tap_keycode(keycode)) {
        case KC_SPC:
        case KC_A ... KC_Z:
        case KC_DOT:
        case KC_COMM:
        case KC_SCLN:
        case KC_SLSH:
        case KC_UNDS:
            return true;
    }
    return false;
}

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case LT(4,KC_BSPC):
        case LT(1,KC_TAB):
        case LT(3,KC_SPC):
        case LT(2,KC_ENT):
            // Immediately select the hold action when another key is tapped.
            return true;
        default:
            // Do not select the hold action when another key is tapped.
            return false;
    }
}
