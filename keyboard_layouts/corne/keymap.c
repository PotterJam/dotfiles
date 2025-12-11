#include QMK_KEYBOARD_H

enum layers {
    GAL,
    SYM,
    NUM,
    FUN,
    NAV,
};

#define LA_SYM OSL(SYM)
#define LA_NUM OSL(NUM)
#define LA_FUN OSL(FUN)
#define LA_NAV LT(NAV, KC_ENT)

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
        KC_ESC,  HRM_N,   HRM_R,   HRM_T,   HRM_S,   KC_G,       KC_P,    HRM_H,   HRM_A,   HRM_E,   HRM_I,   KC_SCLN,
        LA_FUN,  KC_X,    KC_Q,    KC_M,    KC_W,    KC_Z,       KC_K,    KC_F,    KC_QUOT, KC_UNDS, KC_DOT,  KC_NO,
                          LA_NAV,  KC_SPC,  LA_NUM,              OSM(MOD_LSFT), KC_BSPC, LA_SYM
    ),

    [SYM] = LAYOUT_split_3x6_3(
        KC_PERC, KC_ASTR, KC_DQUO, KC_LCBR, KC_LPRN, KC_LBRC,    KC_RBRC, KC_RPRN, KC_RCBR, KC_AT,   KC_TRNS, KC_NO,
        KC_HASH, KC_QUES, KC_MINS, KC_EQL,  KC_COLN, KC_AMPR,    KC_NO,   KC_LCTL, KC_LALT, KC_LGUI, KC_LSFT, KC_TRNS,
        KC_TILD, KC_LT,   KC_BSLS, KC_PLUS, KC_GT,   KC_SLSH,    KC_NO,   KC_GRV,  KC_TRNS, KC_TRNS, KC_TRNS, KC_NO,
                          KC_TRNS, KC_TRNS, KC_EXLM,             KC_NO,   KC_NO,   KC_NO
    ),

    [NUM] = LAYOUT_split_3x6_3(
        KC_NO,   KC_NO,   KC_NO,   KC_LCBR, KC_LPRN, KC_LBRC,    KC_RBRC, KC_7,    KC_8,    KC_9,    KC_MINS, KC_BSLS,
        KC_TRNS, KC_LSFT, KC_LGUI, KC_LALT, KC_LCTL, KC_NO,      KC_SLSH, KC_4,    KC_5,    KC_6,    KC_PLUS, KC_TRNS,
        KC_NO,   KC_NO,   KC_NO,   KC_NO,   KC_NO,   KC_SLSH,    KC_PERC, KC_1,    KC_2,    KC_3,    KC_ASTR, KC_NO,
                          KC_NO,   KC_NO,   KC_NO,               KC_EQL,  KC_DOT,  KC_0
    ),

    [FUN] = LAYOUT_split_3x6_3(
        QK_BOOT, KC_NO,   KC_NO,   KC_VOLD, KC_VOLU, KC_NO,      KC_NO,   KC_F7,   KC_F8,   KC_F9,   KC_F12,  QK_BOOT,
        KC_NO,   KC_LSFT, KC_LGUI, KC_LALT, KC_LCTL, KC_NO,      KC_NO,   KC_F4,   KC_F5,   KC_F6,   KC_F11,  KC_NO,
        KC_TRNS, KC_NO,   KC_NO,   G(KC_V), G(KC_C), KC_NO,      KC_NO,   KC_F1,   KC_F2,   KC_F3,   KC_F10,  KC_NO,
                          KC_NO,   KC_NO,   KC_NO,               KC_NO,   KC_TRNS, KC_TRNS
    ),

    [NAV] = LAYOUT_split_3x6_3(
        KC_TRNS, HYPR(KC_1), HYPR(KC_2), HYPR(KC_3), HYPR(KC_4), HYPR(KC_5),    KC_PGUP, KC_CIRC, KC_UP,   KC_DLR,  KC_PGDN, KC_TRNS,
        KC_TRNS, KC_LSFT,    KC_LGUI,    KC_LALT,    KC_LCTL,    KC_NO,         KC_NO,   KC_LEFT, KC_DOWN, KC_RGHT, KC_DEL,  KC_TRNS,
        KC_NO,   HYPR(KC_6), HYPR(KC_7), HYPR(KC_8), HYPR(KC_9), HYPR(KC_0),    KC_NO,   KC_TAB,  KC_HOME, KC_END,  KC_NO,   KC_NO,
                             KC_NO,      KC_NO,      KC_NO,                     KC_TRNS, KC_TRNS, KC_TRNS
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
        case LA_NAV:
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

enum combo_events {
    XQ_CW,
    BK_THIN_ARROW,
    FW_ARROW,
    FW_THIN_ARROW,
    GT_EQ,
    LT_EQ,
};

const uint16_t PROGMEM xq_combo[] = {KC_X, KC_Q, COMBO_END};
const uint16_t PROGMEM bw_thin_arrow_combo[] = {KC_QUES, KC_MINS, COMBO_END};
const uint16_t PROGMEM fw_arrow_combo[] = {KC_EQL, KC_AMPR, COMBO_END};
const uint16_t PROGMEM fw_thin_arrow_combo[] = {KC_LT, KC_BSLS, COMBO_END};
const uint16_t PROGMEM gt_eq_combo[] = {KC_BSLS, KC_PLUS, COMBO_END};
const uint16_t PROGMEM lt_eq_combo[] = {KC_DQUO, KC_LCBR, COMBO_END};

combo_t key_combos[] = {
    [XQ_CW] = COMBO(xq_combo, CW_TOGG),
    [BK_THIN_ARROW] = COMBO_ACTION(bw_thin_arrow_combo),
    [FW_ARROW] = COMBO_ACTION(fw_arrow_combo),
    [FW_THIN_ARROW] = COMBO_ACTION(fw_thin_arrow_combo),
    [GT_EQ] = COMBO_ACTION(gt_eq_combo),
    [LT_EQ] = COMBO_ACTION(lt_eq_combo),
};

void process_combo_event(uint16_t combo_index, bool pressed) {
    switch(combo_index) {
        case BK_THIN_ARROW:
            if (pressed) { SEND_STRING("<-"); }
            break;
        case FW_ARROW:
            if (pressed) { SEND_STRING("=>"); }
            break;
        case FW_THIN_ARROW:
            if (pressed) { SEND_STRING("->"); }
            break;
        case GT_EQ:
            if (pressed) { SEND_STRING(">="); }
            break;
        case LT_EQ:
            if (pressed) { SEND_STRING("<="); }
            break;
    }
}
