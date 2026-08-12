# Mac setup and rebuild guide

Last inventoried: 11 August 2026

This is a portable record of the useful software and preferences on this Mac. It intentionally excludes passwords, tokens, SSH keys, application databases, logs, window positions, and other transient state.

## Machine baseline

- MacBook Pro (`Mac17,6`), Apple M5 Max, 64 GB RAM
- Apple Silicon (`arm64`)
- macOS 26.5.1 at the time of inventory
- System keyboard input source: U.S.
- Physical keyboard layout: Gallium
- Login shell: Fish (`/opt/homebrew/bin/fish`)
- Default browser: Google Chrome
- Appearance follows the macOS default; Herdr switches Catppuccin themes automatically

Do not try to reproduce the exact OS or app versions below unless debugging a regression. Install current stable releases instead.

## Recommended setup order

1. Complete macOS updates and, for a work machine, company enrollment.
2. Sign in to 1Password before restoring credentials or developer keys.
3. Install the Xcode command-line tools and Homebrew.
4. Install the Brewfile packages below.
5. Set Fish as the login shell.
6. Install the remaining manual, App Store, and company-managed apps.
7. Restore Ghostty and Herdr configuration from this document.
8. Restore VS Code extensions and utility preferences.
9. Sign in to apps and restore SSH/Git credentials from the appropriate secure source.

## Base developer tools

```sh
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Homebrew was installed at `/opt/homebrew`. The current top-level formulae are Fish, Herdr, Hunk, LazyGit, Node, Podman, and Socat. `fzf` is included below because the Herdr cross-tab pane command requires it, even though it was missing when this inventory was made.

Create a temporary `Brewfile` containing:

```ruby
brew "fish"
brew "fzf"
brew "herdr"
brew "modem-dev/tap/hunk"
brew "lazygit"
brew "node"
brew "podman"
brew "socat"

cask "claude"
cask "claude-code"
cask "codex"
cask "raycast"
cask "scroll-reverser"
cask "spotify"
cask "visual-studio-code"
```

Then run:

```sh
brew bundle --file ./Brewfile
brew services start herdr
```

Transitive formulae observed on the old Mac included `ada-url`, `brotli`, `c-ares`, `ca-certificates`, `fmt`, `hdrhistogram_c`, `icu4c@78`, `libffi`, `libnghttp2`, `libnghttp3`, `libngtcp2`, `libuv`, `llhttp`, `lz4`, `merve`, `nbytes`, `openssl@3`, `pcre2`, `readline`, `simdjson`, `simdutf`, `sqlite`, `uvwasi`, `xz`, and `zstd`. Do not install these individually; Homebrew should resolve them.

### Fish shell

```sh
grep -qxF /opt/homebrew/bin/fish /etc/shells || echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
mkdir -p ~/.config/fish
```

Put this in `~/.config/fish/config.fish`:

```fish
# Initialize Homebrew for Apple Silicon, including its binaries, manuals,
# info pages, and environment variables.
eval (/opt/homebrew/bin/brew shellenv fish)

# Keep interactive terminal applications such as lazygit in color.
set --erase NO_COLOR
```

The global Git config only had this non-sensitive preference:

```sh
git config --global core.longpaths true
```

Configure Git identity, signing, credentials, and SSH separately from a secure source.

## Applications

### Installed through Homebrew casks

- Claude desktop
- Claude Code
- Codex
- Raycast
- Scroll Reverser
- Spotify
- Visual Studio Code

### Installed manually

- 1Password
- Ghostty
- Google Chrome
- Notion
- Notion Calendar
- Rectangle
- Slack

For a personal/unmanaged rebuild, most of the manually installed apps can optionally be installed through Homebrew:

```sh
brew install --cask 1password ghostty google-chrome notion notion-calendar rectangle slack zoom
```

## Browser

Google Chrome is the default handler for HTTP, HTTPS, and HTML files. After installing it, open:

`System Settings > Desktop & Dock > Default web browser > Google Chrome`

Restore browser profile, bookmarks, and extensions through the intended account sync. Do not copy browser profile directories between machines.

## Ghostty

Ghostty 1.3.1 was installed manually but for fresh installs use brew. Its active macOS configuration is stored at:

`~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`

It deliberately unbinds Command+1 through Command+9 so Herdr can use those keys for workspace switching.

```ini
keybind = super+1=unbind
keybind = super+digit_1=unbind
keybind = super+2=unbind
keybind = super+digit_2=unbind
keybind = super+3=unbind
keybind = super+digit_3=unbind
keybind = super+4=unbind
keybind = super+digit_4=unbind
keybind = super+5=unbind
keybind = super+digit_5=unbind
keybind = super+6=unbind
keybind = super+digit_6=unbind
keybind = super+7=unbind
keybind = super+digit_7=unbind
keybind = super+8=unbind
keybind = super+digit_8=unbind
keybind = super+9=unbind
keybind = super+digit_9=unbind
```

Create the directory and file, then fully quit and reopen Ghostty:

```sh
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
${EDITOR:-vi} "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

Ghostty automatic update checks were enabled. Window positions and update timestamps are intentionally omitted.

## Herdr

Herdr uses `~/.config/herdr/config.toml` and runs as a Homebrew service. The meaningful active settings are reproduced below. This compact version omits inactive comments and empty configuration tables.

```toml
onboarding = false

[theme]
name = "catppuccin"
auto_switch = true
dark_name = "catppuccin"
light_name = "catppuccin-latte"

[update]
channel = "stable"
version_check = true
manifest_check = true

[keys]
prefix = "ctrl+h"
focus_agent = "cmd+ctrl+1..9"
new_tab = "prefix+t"
previous_tab = ["prefix+p", "cmd+shift+["]
next_tab = ["prefix+n", "cmd+shift+]"]
switch_tab = "ctrl+1..9"
switch_workspace = "cmd+1..9"
focus_pane_left = "prefix+left"
focus_pane_down = "prefix+down"
focus_pane_up = "prefix+up"
focus_pane_right = "prefix+right"

[[keys.command]]
key = "prefix+shift+a"
type = "popup"
command = """
while true; do
  printf 'Agent name: '
  IFS= read -r name || exit 0
  [ -n "$name" ] || exit 0

  if output=$("$HERDR_BIN_PATH" agent rename "$HERDR_ACTIVE_PANE_ID" "$name" 2>&1); then
    exit 0
  fi

  printf '\\n%s\\n\\n' "$output"
done
"""
description = "rename focused agent"
width = 44
height = 7

[[keys.command]]
key = "prefix+l"
type = "popup"
command = "/opt/homebrew/bin/lazygit"
description = "open lazygit"
width = "95%"
height = "95%"

[[keys.command]]
key = "prefix+d"
type = "popup"
command = """
set -u

cwd=${HERDR_ACTIVE_PANE_CWD:-$PWD}
if repo=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
  :
else
  repos=$(mktemp)
  trap 'rm -f "$repos"' EXIT HUP INT TERM
  find "$HOME/git" -mindepth 2 -maxdepth 2 -type d -name .git -print 2>/dev/null |
    sed 's#/.git$##' |
    sort > "$repos"

  if [ ! -s "$repos" ]; then
    printf 'Hunk needs a Git repository, and none were found under ~/git.\n\nPress Enter to close.'
    IFS= read -r _
    exit 1
  fi

  printf 'Choose a repository for Hunk:\n\n'
  awk '{ printf "  %d) %s\\n", NR, $0 }' "$repos"
  printf '\nRepository number (blank cancels): '
  IFS= read -r choice
  [ -n "$choice" ] || exit 0
  case $choice in *[!0-9]*) exit 0 ;; esac
  repo=$(sed -n "${choice}p" "$repos")
  [ -n "$repo" ] || exit 0
fi

cd "$repo" || exit 1
/opt/homebrew/bin/hunk diff --watch
status=$?
if [ "$status" -ne 0 ]; then
  printf '\nHunk exited with status %s. Press Enter to close.' "$status"
  IFS= read -r _
fi
exit "$status"
"""
description = "review changes in Hunk"
width = "95%"
height = "95%"

[[keys.command]]
key = "prefix+m"
type = "shell"
command = "\"$HERDR_BIN_PATH\" pane zoom \"$HERDR_ACTIVE_PANE_ID\" --off >/dev/null 2>&1; \"$HERDR_BIN_PATH\" pane move \"$HERDR_ACTIVE_PANE_ID\" --new-tab --focus"
description = "move focused pane to a new tab"

[[keys.command]]
key = "prefix+shift+m"
type = "popup"
command = """
set -eu

herdr=${HERDR_BIN_PATH:?HERDR_BIN_PATH is required}
source_pane=${HERDR_ACTIVE_PANE_ID:?HERDR_ACTIVE_PANE_ID is required}
source_tab=${HERDR_ACTIVE_TAB_ID:?HERDR_ACTIVE_TAB_ID is required}
source_workspace=${HERDR_ACTIVE_WORKSPACE_ID:?HERDR_ACTIVE_WORKSPACE_ID is required}
snapshot=$("$herdr" api snapshot)

target_tab=$(printf '%s\\n' "$snapshot" |
  jq -r --arg source_tab "$source_tab" --arg source_workspace "$source_workspace" '
    .result.snapshot as $session
    | $session.tabs[]
    | select(.workspace_id == $source_workspace and .tab_id != $source_tab)
    | . as $tab
    | [$tab.tab_id, ("tab " + ($tab.number | tostring)), $tab.label]
    | @tsv
  ' |
  fzf --prompt='move pane to tab> ' --header='tab   label' --delimiter='\\t' --with-nth=2..
) || exit 0

target_tab=$(printf '%s\\n' "$target_tab" | cut -f1)
[ -n "$target_tab" ] || exit 0

target_pane=$(printf '%s\\n' "$snapshot" |
  jq -r --arg target_tab "$target_tab" '
    .result.snapshot.layouts[]
    | select(.tab_id == $target_tab)
    | .focused_pane_id
  ')

[ -n "$target_pane" ] || exit 1

"$herdr" pane zoom "$source_pane" --off >/dev/null 2>&1 || true
"$herdr" pane zoom "$target_pane" --off >/dev/null 2>&1 || true
exec "$herdr" pane move "$source_pane" --tab "$target_tab" --target-pane "$target_pane" --split right --focus
"""
description = "move focused pane into another tab"
width = "90%"
height = "90%"

[ui]
prompt_new_tab_name = false
agent_panel_sort = "priority"

[experimental]
kitty_graphics = true
pane_history = false
```

Apply and check it with:

```sh
mkdir -p ~/.config/herdr
${EDITOR:-vi} ~/.config/herdr/config.toml
herdr config check
brew services restart herdr
```

Important shortcuts:

| Action | Shortcut |
|---|---|
| Herdr prefix | Control+H |
| Open LazyGit popup | Prefix, then L |
| Review changes in Hunk | Prefix, then D |
| New tab | Prefix, then T |
| Previous / next tab | Prefix+P / Prefix+N |
| Switch tab | Control+1…9 |
| Switch workspace | Command+1…9 |
| Focus agent | Command+Control+1…9 |
| Move pane to new tab | Prefix, then M |
| Move pane to another tab | Prefix, then Shift+M |
| Rename focused agent | Prefix, then Shift+A |

## VS Code

Installed extensions at inventory time:

```text
ms-dotnettools.csdevkit
ms-dotnettools.csharp
ms-dotnettools.vscode-dotnet-runtime
```

Restore them with:

```sh
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.vscode-dotnet-runtime
```

Use VS Code Settings Sync for editor settings and keybindings if appropriate.

## Window, launcher, and scrolling utilities

### Raycast

- Global hotkey: Command+Space
- The corresponding Spotlight shortcuts were disabled
- Restore Raycast settings/extensions through Raycast sync or its export/import feature

Disable the two Spotlight keyboard shortcuts manually in:

`System Settings > Keyboard > Keyboard Shortcuts > Spotlight`

### Rectangle

Observed preferences:

- Automatic update checks disabled
- Allow any shortcut enabled
- Alternate default shortcuts enabled
- Subsequent execution mode set to `1`
- Toggle Todo shortcut stored as Control+Option+B (hardware key code 11)
- Reflow Todo shortcut stored as Control+Option+N (hardware key code 45)

The exact low-level values can be restored after installing and quitting Rectangle:

```sh
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
defaults write com.knollsoft.Rectangle toggleTodo -dict keyCode -int 11 modifierFlags -int 786432
defaults write com.knollsoft.Rectangle reflowTodo -dict keyCode -int 45 modifierFlags -int 786432
```

Because Gallium changes the produced characters, verify these shortcuts by physical key position after restoring them.

### Scroll Reverser

- Scroll reversing enabled globally
- Trackpad reversing disabled
- Discrete-scroll options shown

Restore after installing and quitting the app:

```sh
defaults write com.pilotmoon.scroll-reverser InvertScrollingOn -bool true
defaults write com.pilotmoon.scroll-reverser ReverseTrackpad -bool false
defaults write com.pilotmoon.scroll-reverser ShowDiscreteScrollOptions -bool true
```

Grant Accessibility/Input Monitoring permissions again when prompted.

## macOS preferences worth restoring

- Dock position: right
- Dock contents observed: Google Chrome, Notes, System Settings
- Default browser: Google Chrome
- Keyboard input source: U.S.; Gallium is provided by the physical keyboard/firmware setup rather than a macOS input source
- Spotlight Command+Space shortcuts disabled so Raycast can own Command+Space
- Most inspected keyboard repeat, Finder, screenshot, appearance, and Dock auto-hide settings were left at macOS defaults

Restore the Dock position with:

```sh
defaults write com.apple.dock orientation -string right
killall Dock
```

Dock item ordering is easiest to restore manually.

## Runtimes and containers

Observed versions, for reference only:

- Node.js 26.7.0, npm 11.19.0 (Homebrew)
- .NET SDK 10.0.302
- Apple-provided Python 3.9.6
- Podman client 6.0.2; no Podman machine was listed
- Apple Git 2.50.1
- Fish 4.8.1

The .NET SDK was not recorded as a Homebrew package, so install the current required SDK from Microsoft or the company's standard software source. Do not rely on the Apple system Python for project tooling; install a managed Python version if a project needs it.

## Current application version snapshot

These versions are an audit trail, not pins:

| App | Version |
|---|---:|
| 1Password | 8.12.30 |
| Claude | 1.26832.0 |
| Ghostty | 1.3.1 |
| Google Chrome | 151.0.7922.109 |
| Notion | 7.29.0 |
| Notion Calendar | 1.139.0 |
| Raycast | 1.104.24 |
| Rectangle | 0.98 |
| Scroll Reverser | 1.9 |
| Slack | 4.51.180 |
| Spotify | 1.2.95.453 |
| Visual Studio Code | 1.132.0 |

## Final verification checklist

- `brew doctor` is acceptably clean
- `fish` is the login shell and `brew`, `herdr`, `hunk`, `lazygit`, `fzf`, `node`, `code`, `claude`, and `codex` resolve in a fresh terminal
- Chrome is the default browser
- Raycast opens with Command+Space
- Ghostty passes Command+1…9 through to Herdr
- `herdr config check` passes and Herdr starts at login
- Prefix+L opens LazyGit
- Prefix+D opens Hunk and watches the current repository diff
- Herdr pane-to-tab commands work
- VS Code has the three .NET extensions
- Rectangle and Scroll Reverser have their required Accessibility/Input Monitoring permissions
- Git identity, signing, SSH keys, and package registry credentials have been restored securely
