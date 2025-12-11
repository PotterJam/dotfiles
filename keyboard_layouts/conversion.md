# ZMK to QMK Conversion Reference

## Hold-Tap Behaviors

| ZMK | QMK |
|-----|-----|
| `&mt LSHIFT X` (mod-tap) | `LSFT_T(KC_X)` |
| `&mt LGUI X` | `LGUI_T(KC_X)` |
| `&mt LALT X` | `LALT_T(KC_X)` |
| `&mt LCTRL X` | `LCTL_T(KC_X)` |
| `&lt LAYER X` (layer-tap) | `LT(LAYER, KC_X)` |

### Balanced Hold-Tap with Opposite Hand Triggering (HRM)

ZMK:
```
lhrm: left_homerow_mod {
    compatible = "zmk,behavior-hold-tap";
    flavor = "balanced";
    hold-trigger-key-positions = <RIGHT_HAND_KEYS>;
};
```

QMK (config.h):
```c
#define CHORDAL_HOLD
```

QMK (keymap.c):
```c
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT(
    'L', 'L', 'L', ...    'R', 'R', 'R', ...
    'L', 'L', 'L', ...    'R', 'R', 'R', ...
              '*', '*',        '*', '*'
);
```
Use `'L'` for left hand, `'R'` for right hand, `'*'` for thumb keys.

### Timing Parameters

| ZMK | QMK (config.h) |
|-----|----------------|
| `tapping-term-ms = <200>` | `#define TAPPING_TERM 200` |
| `quick-tap-ms = <150>` | `#define QUICK_TAP_TERM 150` |
| `require-prior-idle-ms = <135>` | `#define FLOW_TAP_TERM 135` + flow tap functions |

Flow tap implementation (keymap.c):
```c
bool is_flow_tap_key(uint16_t keycode) {
    if ((get_mods() & (MOD_MASK_CG | MOD_BIT_LALT)) != 0) {
        return false;
    }
    switch (get_tap_keycode(keycode)) {
        case KC_SPC:
        case KC_A ... KC_Z:
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
```

## Sticky Keys / One-Shot

| ZMK | QMK |
|-----|-----|
| `&sk LSHFT` | `OSM(MOD_LSFT)` |
| `&sk LGUI` | `OSM(MOD_LGUI)` |
| `&sk LALT` | `OSM(MOD_LALT)` |
| `&sk LCTRL` | `OSM(MOD_LCTL)` |
| `&sl LAYER` (sticky layer) | `OSL(LAYER)` |

## Layer Access

| ZMK | QMK |
|-----|-----|
| `&mo LAYER` (momentary) | `MO(LAYER)` |
| `&to LAYER` (toggle) | `TO(LAYER)` |
| `&tog LAYER` | `TG(LAYER)` |
| `&sl LAYER` (one-shot layer) | `OSL(LAYER)` |
| `&lt LAYER X` | `LT(LAYER, KC_X)` |

## Modifier Keys

| ZMK | QMK |
|-----|-----|
| `&kp LSHFT` | `KC_LSFT` |
| `&kp LGUI` | `KC_LGUI` |
| `&kp LALT` | `KC_LALT` |
| `&kp LCTRL` | `KC_LCTL` |
| `&kp LG(X)` (GUI+X) | `G(KC_X)` |
| `&kp LA(X)` (ALT+X) | `A(KC_X)` |
| `&kp LC(X)` (CTRL+X) | `C(KC_X)` |
| `&kp LS(X)` (SHIFT+X) | `S(KC_X)` |
| `&kp LG(LA(LC(LS(X))))` (hyper) | `HYPR(KC_X)` |

## Common Keys

| ZMK | QMK |
|-----|-----|
| `&kp SPACE` | `KC_SPC` |
| `&kp BACKSPACE` | `KC_BSPC` |
| `&kp ENTER` / `&kp RET` | `KC_ENT` |
| `&kp TAB` | `KC_TAB` |
| `&kp ESCAPE` | `KC_ESC` |
| `&kp DELETE` | `KC_DEL` |
| `&trans` | `KC_TRNS` |
| `&none` | `KC_NO` |

## Symbols

| ZMK | QMK |
|-----|-----|
| `&kp EXCL` | `KC_EXLM` |
| `&kp AT` | `KC_AT` |
| `&kp HASH` | `KC_HASH` |
| `&kp DLLR` | `KC_DLR` |
| `&kp PRCNT` | `KC_PERC` |
| `&kp CARET` | `KC_CIRC` |
| `&kp AMPS` | `KC_AMPR` |
| `&kp ASTRK` / `&kp STAR` | `KC_ASTR` |
| `&kp LPAR` | `KC_LPRN` |
| `&kp RPAR` | `KC_RPRN` |
| `&kp LBKT` | `KC_LBRC` |
| `&kp RBKT` | `KC_RBRC` |
| `&kp LBRC` | `KC_LCBR` |
| `&kp RBRC` | `KC_RCBR` |
| `&kp MINUS` | `KC_MINS` |
| `&kp UNDER` | `KC_UNDS` |
| `&kp EQUAL` | `KC_EQL` |
| `&kp PLUS` | `KC_PLUS` |
| `&kp BSLH` | `KC_BSLS` |
| `&kp PIPE` | `KC_PIPE` |
| `&kp SEMI` | `KC_SCLN` |
| `&kp COLON` | `KC_COLN` |
| `&kp SQT` | `KC_QUOT` |
| `&kp DQT` | `KC_DQUO` |
| `&kp COMMA` | `KC_COMM` |
| `&kp DOT` | `KC_DOT` |
| `&kp FSLH` / `&kp SLASH` | `KC_SLSH` |
| `&kp QMARK` | `KC_QUES` |
| `&kp GRAVE` | `KC_GRV` |
| `&kp TILDE` | `KC_TILD` |
| `&kp LT` | `KC_LT` |
| `&kp GT` | `KC_GT` |

## Navigation

| ZMK | QMK |
|-----|-----|
| `&kp UP` | `KC_UP` |
| `&kp DOWN` | `KC_DOWN` |
| `&kp LEFT` | `KC_LEFT` |
| `&kp RIGHT` | `KC_RGHT` |
| `&kp HOME` | `KC_HOME` |
| `&kp END` | `KC_END` |
| `&kp PG_UP` | `KC_PGUP` |
| `&kp PG_DN` | `KC_PGDN` |

## Function Keys

| ZMK | QMK |
|-----|-----|
| `&kp F1` - `&kp F12` | `KC_F1` - `KC_F12` |

## Media

| ZMK | QMK |
|-----|-----|
| `&kp C_VOL_UP` | `KC_VOLU` |
| `&kp C_VOL_DN` | `KC_VOLD` |
| `&kp C_MUTE` | `KC_MUTE` |

## Special Behaviors

| ZMK | QMK |
|-----|-----|
| `&caps_word` | `CW_TOGG` (requires `CAPS_WORD_ENABLE = yes` in rules.mk) |
| `&bootloader` | `QK_BOOT` |
| `&sys_reset` | `QK_RBT` |

## Combos

ZMK (in .keymap):
```
combos {
    combo_caps {
        key-positions = <24 25>;
        bindings = <&caps_word>;
    };
};
```

QMK (keymap.c):
```c
enum combo_events { COMBO_NAME };
const uint16_t PROGMEM combo_keys[] = {KC_X, KC_Y, COMBO_END};
combo_t key_combos[] = {
    [COMBO_NAME] = COMBO(combo_keys, KC_OUTPUT),
};
```

For string output combos:
```c
combo_t key_combos[] = {
    [COMBO_NAME] = COMBO_ACTION(combo_keys),
};

void process_combo_event(uint16_t combo_index, bool pressed) {
    switch(combo_index) {
        case COMBO_NAME:
            if (pressed) { SEND_STRING("output"); }
            break;
    }
}
```

QMK (rules.mk):
```
COMBO_ENABLE = yes
```

QMK (config.h):
```c
#define COMBO_TERM 50
```

## Required rules.mk Features

| Feature | rules.mk |
|---------|----------|
| Caps Word | `CAPS_WORD_ENABLE = yes` |
| Combos | `COMBO_ENABLE = yes` |
| Key Overrides | `KEY_OVERRIDE_ENABLE = yes` |

## Required config.h Defines

```c
#define PERMISSIVE_HOLD_PER_KEY
#define CHORDAL_HOLD
#define FLOW_TAP_TERM 135
#define COMBO_TERM 50
#define TAPPING_TERM 200
#define QUICK_TAP_TERM 150
```
