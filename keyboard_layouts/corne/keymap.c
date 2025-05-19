#include QMK_KEYBOARD_H

#include "oneshot.h"

#define LA_NAV MO(NAV)
#define LA_SYM MO(SYM)
#define LA_FKEY MO(FKEY)

enum layers {
    DEF,
    NAV,
    SYM,
    NUM,
    FKEY,
};

enum keycodes {
    // Custom oneshot mod implementation with no timers.
    OS_SHFT = SAFE_RANGE,
    OS_CTRL,
    OS_ALT,
    OS_CMD,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [DEF] = LAYOUT_split_3x6_3(
        KC_NO, KC_B, KC_L, KC_D, KC_C, KC_V, KC_J, KC_Y, KC_O, KC_U, KC_COMM, KC_NO,
        KC_NO, KC_N, KC_R, KC_T, KC_S, KC_G, KC_P, KC_H, KC_A, KC_E, KC_I, KC_NO,
        KC_NO, KC_X, KC_Q, KC_M, KC_W, KC_Z, KC_K, KC_F, KC_QUOT, KC_SCLN, KC_DOT, KC_NO,
                KC_NO, LA_NAV, OS_SHFT, KC_SPC, LA_SYM, KC_NO),

    [NAV] = LAYOUT_split_3x6_3(
        KC_NO, KC_ESC, OSM(MOD_LCTL), KC_TAB, KC_C, KC_V, KC_NO, KC_HOME, KC_UP, KC_END, KC_DEL, KC_NO,
        KC_NO, OS_SHFT, OS_CMD, OS_ALT, OS_CTRL, KC_BSPC, KC_CAPS, KC_LEFT, KC_DOWN, KC_RGHT, KC_BSPC, KC_NO,
        KC_NO, KC_NO, KC_NO, LA_FKEY, KC_ENT, LGUI(KC_Z), KC_INS, KC_ENT, CW_TOGG, KC_PGUP, KC_PGDN, KC_NO,
                KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO),

    [SYM] = LAYOUT_split_3x6_3(KC_NO, KC_ESC, KC_LBRC, KC_LCBR, KC_LPRN, KC_CIRC, KC_NO, KC_RPRN, KC_RCBR, KC_RBRC, KC_PERC, KC_NO,
        KC_NO, KC_EXLM, KC_PMNS, KC_PPLS, KC_PEQL, KC_HASH, KC_TILD, KC_COLN, KC_UNDS, KC_GT, KC_QUES, KC_NO,
        KC_NO, KC_PAST, KC_AMPR, KC_PIPE, KC_PSLS, KC_GRV, KC_NO, KC_BSLS, KC_DLR, KC_LT, KC_AT, KC_NO,
                KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO),

    [NUM] = LAYOUT_split_3x6_3(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_PMNS, KC_7, KC_8, KC_9, KC_PSLS, KC_NO,
        KC_NO, OS_SHFT, OS_CMD, OS_ALT, OS_CTRL, KC_NO, KC_PLUS, KC_4, KC_5, KC_6, KC_0, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_ASTR, KC_1, KC_2, KC_3, KC_DOT, KC_NO,
                KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO),

    [FKEY] = LAYOUT_split_3x6_3(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_F7, KC_F8, KC_F9, KC_F10, KC_NO,
        KC_NO, OS_SHFT, OS_CMD, OS_ALT, OS_CTRL, KC_NO, KC_NO, KC_F4, KC_F5, KC_F6, KC_F11, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_F1, KC_F2, KC_F3, KC_F12, KC_NO,
                KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_NO)
};

bool is_oneshot_cancel_key(uint16_t keycode) {
    switch (keycode) {
    case LA_SYM:
    case LA_NAV:
        return true;
    default:
        return false;
    }
}

bool is_oneshot_ignored_key(uint16_t keycode) {
    switch (keycode) {
    case LA_SYM:
    case LA_NAV:
    case KC_LSFT:
    case OS_SHFT:
    case OS_CTRL:
    case OS_ALT:
    case OS_CMD:
        return true;
    default:
        return false;
    }
}

oneshot_state os_shft_state = os_up_unqueued;
oneshot_state os_ctrl_state = os_up_unqueued;
oneshot_state os_alt_state = os_up_unqueued;
oneshot_state os_cmd_state = os_up_unqueued;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    update_oneshot(
        &os_shft_state, KC_LSFT, OS_SHFT,
        keycode, record
    );
    update_oneshot(
        &os_ctrl_state, KC_LCTL, OS_CTRL,
        keycode, record
    );
    update_oneshot(
        &os_alt_state, KC_LALT, OS_ALT,
        keycode, record
    );
    update_oneshot(
        &os_cmd_state, KC_LCMD, OS_CMD,
        keycode, record
    );

    return true;
}

layer_state_t layer_state_set_user(layer_state_t state) {
    return update_tri_layer_state(state, NAV, SYM, NUM);
}
