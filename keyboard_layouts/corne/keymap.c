#include QMK_KEYBOARD_H

enum layers {
    GAL,
    SYM,
    NUM,
    FUN,
    NAV,
};

enum custom_keycodes {
    CU_LT = SAFE_RANGE,
    CU_GT,
    CU_PIPE,
    CU_OSFT,
    CU_SYM,
    CU_NAV,
};

#define LA_NUM LT(NUM, KC_ENT)
#define LA_FUN MO(FUN)

#define HRM_N LSFT_T(KC_N)
#define HRM_R LGUI_T(KC_R)
#define HRM_T LALT_T(KC_T)
#define HRM_S LCTL_T(KC_S)
#define HRM_H LCTL_T(KC_H)
#define HRM_A LALT_T(KC_A)
#define HRM_E LGUI_T(KC_E)
#define HRM_I LSFT_T(KC_I)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [GAL] = LAYOUT_split_3x6_3(
        KC_HOME, KC_B,    KC_L,    KC_D,    KC_C,    KC_V,       KC_J,    KC_Y,    KC_O,    KC_U,    KC_COMM, KC_END,
        KC_ESC,  HRM_N,   HRM_R,   HRM_T,   HRM_S,   KC_G,       KC_P,    HRM_H,   HRM_A,   HRM_E,   HRM_I,   KC_SLSH,
        LA_FUN,  KC_X,    KC_Q,    KC_M,    KC_W,    KC_Z,       KC_K,    KC_F,    KC_QUOT, KC_UNDS, KC_DOT,  KC_NO,
                          CU_NAV,  KC_BSPC, CU_OSFT,             LA_NUM,  KC_SPC,  CU_SYM
    ),

    [SYM] = LAYOUT_split_3x6_3(
        KC_PERC, KC_LCBR, KC_LPRN, KC_RPRN, KC_SCLN, KC_RCBR,    G(KC_LBRC), KC_LCTL, KC_LALT, KC_LGUI, KC_LSFT, G(KC_RBRC),
        KC_HASH, KC_QUES, KC_ASTR, KC_EQL,  KC_DQUO, KC_AMPR,    KC_DEL,  KC_BSPC, KC_TAB,  KC_SPC,  KC_ENT,  KC_TRNS,
        KC_TILD, CU_LT,   CU_PIPE, KC_MINS, CU_GT,   KC_PLUS,    KC_GRV,  KC_LBRC, S(KC_TAB), KC_RBRC, KC_TRNS, KC_TRNS,
                          KC_AT,   KC_COLN, KC_EXLM,             KC_TRNS, KC_TRNS, KC_TRNS
    ),

    [NUM] = LAYOUT_split_3x6_3(
        KC_PERC, KC_ASTR, KC_7,    KC_8,    KC_9,    KC_BSLS,    G(KC_LBRC), KC_LCTL, KC_LALT, KC_LGUI, KC_LSFT, G(KC_RBRC),
        KC_HASH, KC_MINS, KC_4,    KC_5,    KC_6,    KC_PLUS,    KC_DEL,  KC_BSPC, KC_TAB,  KC_SPC,  KC_ENT,  KC_TRNS,
        KC_GRV,  KC_UNDS, KC_1,    KC_2,    KC_3,    KC_SLSH,    KC_GRV,  KC_LBRC, S(KC_TAB), KC_RBRC, KC_TRNS, KC_TRNS,
                          KC_EQL,  KC_0,    KC_DOT,              KC_TRNS, KC_TRNS, KC_TRNS
    ),

    [FUN] = LAYOUT_split_3x6_3(
        QK_BOOT, KC_NO,   KC_NO,   KC_VOLD, KC_VOLU, KC_NO,      KC_NO,   KC_F7,   KC_F8,   KC_F9,   KC_F12,  QK_BOOT,
        KC_NO,   KC_LSFT, KC_LGUI, KC_LALT, KC_LCTL, KC_NO,      KC_NO,   KC_F4,   KC_F5,   KC_F6,   KC_F11,  KC_NO,
        KC_TRNS, KC_NO,   KC_NO,   G(KC_V), G(KC_C), KC_NO,      KC_NO,   KC_F1,   KC_F2,   KC_F3,   KC_F10,  KC_NO,
                          KC_TRNS,   KC_TRNS,   KC_TRNS,               KC_TRNS,   KC_TRNS, KC_TRNS
    ),

    [NAV] = LAYOUT_split_3x6_3(
        KC_TRNS, HYPR(KC_1), HYPR(KC_2), HYPR(KC_3), HYPR(KC_4), HYPR(KC_5),    KC_PGUP, KC_CIRC, KC_UP,   KC_DLR,  KC_PGDN, KC_TRNS,
        KC_TRNS, KC_LSFT,    KC_LGUI,    KC_LALT,    KC_LCTL,    KC_NO,         KC_NO,   KC_LEFT, KC_DOWN, KC_RGHT, KC_DEL,  KC_TRNS,
        KC_NO,   HYPR(KC_6), HYPR(KC_7), HYPR(KC_8), HYPR(KC_9), HYPR(KC_0),    KC_NO,   KC_TAB,  S(KC_TAB), KC_NO, KC_NO,   KC_NO,
                             KC_TRNS,    KC_TRNS,    KC_TRNS,                   KC_TRNS, KC_TRNS, KC_TRNS
    ),
};

const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT_split_3x6_3(
    'L', 'L', 'L', 'L', 'L', 'L',    'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L',    'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L',    'R', 'R', 'R', 'R', 'R', 'R',
              '*', '*', '*',             '*', '*', '*'
);

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case HRM_N:
        case HRM_R:
        case HRM_T:
        case HRM_S:
        case HRM_H:
        case HRM_A:
        case HRM_E:
        case HRM_I:
        case LA_NUM:
            return true;
        default:
            return false;
    }
}

bool is_flow_tap_key(uint16_t keycode) {
    if ((get_mods() & (MOD_MASK_CG | MOD_BIT_LALT)) != 0) {
        return false;
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
        return FLOW_TAP_TERM;
    }
    return 0;
}


static bool osft_held;
static bool sym_held;
static bool nav_held;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.pressed) {
        if (osft_held && keycode != CU_OSFT) osft_held = false;
        if (sym_held && keycode != CU_SYM) sym_held = false;
        if (nav_held && keycode != CU_NAV) nav_held = false;
    }

    switch (keycode) {
        case CU_LT:
            if (record->event.pressed) {
                tap_code16(KC_LT);
                clear_weak_mods();
            }
            return false;
        case CU_GT:
            if (record->event.pressed) {
                tap_code16(KC_GT);
                clear_weak_mods();
            }
            return false;
        case CU_PIPE:
            if (record->event.pressed) {
                tap_code16(KC_PIPE);
                clear_weak_mods();
            }
            return false;
        case CU_OSFT:
            if (record->event.pressed) {
                osft_held = true;
                register_mods(MOD_BIT(KC_LSFT));
            } else {
                unregister_mods(MOD_BIT(KC_LSFT));
                if (osft_held) {
                    set_oneshot_mods(MOD_BIT(KC_LSFT));
                }
                osft_held = false;
            }
            return false;
        case CU_SYM:
            if (record->event.pressed) {
                sym_held = true;
                layer_on(SYM);
            } else {
                layer_off(SYM);
                if (sym_held) {
                    set_oneshot_layer(SYM, ONESHOT_START);
                    clear_oneshot_layer_state(ONESHOT_PRESSED);
                }
                sym_held = false;
            }
            return false;
        case CU_NAV:
            if (record->event.pressed) {
                nav_held = true;
                layer_on(NAV);
            } else {
                layer_off(NAV);
                if (nav_held) {
                    set_oneshot_layer(NAV, ONESHOT_START);
                    clear_oneshot_layer_state(ONESHOT_PRESSED);
                }
                nav_held = false;
            }
            return false;
    }
    return true;
}
