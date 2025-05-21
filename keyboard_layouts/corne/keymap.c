#include QMK_KEYBOARD_H

#define LA_NAV MO(NAV)
#define LA_SYM MO(SYM)
#define LA_NUM MO(NUM)

enum layers {
    DEF,
    NAV,
    SYM,
    NUM,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [DEF] = LAYOUT_split_3x6_3(
        KC_NO, KC_B, KC_L, KC_D, KC_C, KC_V, KC_J, KC_Y, KC_O, KC_U, KC_COMM, KC_NO,
        KC_NO, KC_N, KC_R, KC_T, KC_S, KC_G, KC_P, KC_H, KC_A, KC_E, KC_I, KC_NO,
        KC_NO, KC_X, KC_Q, KC_M, KC_W, KC_Z, KC_K, KC_F, KC_QUOT, KC_SCLN, KC_DOT, KC_NO,
                KC_NO, LA_NAV, OSM(MOD_LSFT), KC_SPC, LA_SYM, KC_NO),

    [NAV] = LAYOUT_split_3x6_3(KC_NO, KC_ESC, OSM(MOD_LCTL), KC_TAB, KC_C, KC_V, KC_NO, KC_HOME, KC_UP, KC_END, KC_DEL, KC_NO, KC_NO, OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_BSPC, KC_NO, KC_LEFT, KC_DOWN, KC_RGHT, KC_BSPC, KC_NO, KC_NO, KC_NO, KC_LGUI, KC_LALT, KC_ENT, LGUI(KC_Z), KC_NO, KC_ENT, CW_TOGG, KC_PGUP, KC_PGDN, KC_NO, KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO),

    [SYM] = LAYOUT_split_3x6_3(KC_NO, KC_ESC, KC_LBRC, KC_LCBR, KC_LPRN, KC_PIPE, KC_CIRC, KC_RPRN, KC_RCBR, KC_RBRC, KC_DLR, KC_NO, KC_NO, KC_DQUO, KC_PMNS, KC_UNDS, KC_PEQL, KC_AMPR, KC_HASH, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT), KC_NO, KC_NO, KC_EXLM, KC_PPLS, KC_PAST, KC_PSLS, KC_GRV, KC_PERC, KC_LT, KC_GT, KC_TILD, KC_AT, KC_NO, KC_NO, KC_TRNS, KC_COLN, KC_TRNS, KC_TRNS, KC_NO),

    [NUM] = LAYOUT_split_3x6_3(KC_NO, KC_F9, KC_F10, KC_F11, KC_F12, KC_F6, KC_NO, KC_7, KC_8, KC_9, KC_BSLS, KC_NO, KC_NO, OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_F7, KC_NO, KC_4, KC_5, KC_6, KC_0, KC_NO, KC_NO, KC_F2, KC_F3, KC_F4, KC_F5, KC_F8, KC_NO, KC_1, KC_2, KC_3, KC_DOT, KC_NO, KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO)
};

// Shift . is ?
const key_override_t dot_key_override = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, KC_QUES);

const key_override_t* key_overrides[] = {
    &dot_key_override,
};

bool get_hold_on_other_key_press(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case LA_NAV:
        case LA_SYM:
        case LA_NUM:
            return true;
        default:
            return false;
    }
}

layer_state_t layer_state_set_user(layer_state_t state) {
    return update_tri_layer_state(state, NAV, SYM, NUM);
}
