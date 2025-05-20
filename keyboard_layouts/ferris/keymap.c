#include QMK_KEYBOARD_H

#define LA_NAV MO(NAV)
#define LA_SYM MO(SYM)
#define LA_NUM MO(NUM)
#define LA_FKEY MO(FKEY)

enum layers {
    DEF,
    NAV,
    SYM,
    NUM,
    FKEY,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [DEF] = LAYOUT_split_3x5_2(
        KC_B, KC_L, KC_D, KC_C, KC_V, KC_J, KC_Y, KC_O, KC_U, KC_COMM, 
        KC_N, KC_R, KC_T, KC_S, KC_G, KC_P, KC_H, KC_A, KC_E, KC_I, 
        KC_X, KC_Q, KC_M, KC_W, KC_Z, KC_K, KC_F, KC_QUOT, KC_SCLN, KC_DOT, 
                LA_NAV, OSM(MOD_LSFT), KC_SPC, LA_SYM),

    [NAV] = LAYOUT_split_3x5_2(
        KC_ESC, OSM(MOD_LCTL), KC_TAB, KC_C, KC_V, KC_NO, KC_HOME, KC_UP, KC_END, KC_DEL, 
        OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_BSPC, KC_CAPS, KC_LEFT, KC_DOWN, KC_RGHT, KC_BSPC, 
        KC_NO, KC_NO, LA_FKEY, KC_ENT, LGUI(KC_Z), KC_INS, KC_ENT, CW_TOGG, KC_PGUP, KC_PGDN, 
                KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),

    [SYM] = LAYOUT_split_3x5_2(
        KC_ESC, KC_LBRC, KC_LCBR, KC_LPRN, KC_CIRC, KC_PERC, KC_RPRN, KC_RCBR, KC_RBRC, KC_AT,
        KC_PPLS, KC_PMNS, KC_UNDS, KC_PEQL, KC_HASH, KC_TILD, OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_LSFT),
        KC_EXLM, KC_PIPE, KC_PAST, KC_PSLS, KC_GRV, KC_NO, KC_BSLS, KC_DLR, KC_AMPR, KC_QUES,
                KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),

    [NUM] = LAYOUT_split_3x5_2(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_PMNS, KC_7, KC_8, KC_9, KC_PSLS,
        OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_NO, KC_PLUS, KC_4, KC_5, KC_6, KC_0,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_ASTR, KC_1, KC_2, KC_3, KC_DOT,
                KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),

    [FKEY] = LAYOUT_split_3x5_2(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_F7, KC_F8, KC_F9, KC_F10,
        OSM(MOD_LSFT), OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), KC_NO, KC_NO, KC_F4, KC_F5, KC_F6, KC_F11,
        KC_NO, KC_NO, KC_NO, KC_NO, EE_CLR, KC_NO, KC_F1, KC_F2, KC_F3, KC_F12,
                KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS),
};

enum custom_keycodes {
    THICK_ARROW_RIGHT = SAFE_RANGE,
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
    case THICK_ARROW_RIGHT:
        if (record->event.pressed) {
            SEND_STRING("=> ");
        }
        break;
    }
    return true;
};

const uint16_t PROGMEM arrow_combo[] = {KC_PEQL, KC_HASH, COMBO_END};
combo_t key_combos[] = {
    COMBO(arrow_combo, THICK_ARROW_RIGHT),
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
