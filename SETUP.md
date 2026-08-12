# Mac setup and rebuild guide

Last inventoried: 12 August 2026

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

1. Complete macOS updates.
2. Sign in to 1Password before restoring credentials or developer keys.
3. Install the Xcode command-line tools and Homebrew.
4. Install the Brewfile packages below.
5. Set Fish as the login shell.
6. Install the remaining manually managed apps.
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
- Zoom

Most of the manually installed apps can optionally be installed through Homebrew:

```sh
brew install --cask 1password ghostty google-chrome notion notion-calendar rectangle slack zoom
```

## Browser

Google Chrome is the default handler for HTTP, HTTPS, and HTML files. After installing it, open:

`System Settings > Desktop & Dock > Default web browser > Google Chrome`

Restore browser profile, bookmarks, and extensions through the intended account sync. Do not copy browser profile directories between machines.

## Ghostty

Ghostty 1.3.1 was installed manually. Its active macOS configuration is stored at:

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
key = "prefix+c"
type = "shell"
command = "$HOME/.config/herdr/send-hunk-comments.sh"
description = "send Hunk comments to an agent"

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
| Send Hunk comments to an agent | Prefix, then C |
| New tab | Prefix, then T |
| Previous / next tab | Prefix+P / Prefix+N |
| Switch tab | Control+1…9 |
| Switch workspace | Command+1…9 |
| Focus agent | Command+Control+1…9 |
| Move pane to new tab | Prefix, then M |
| Move pane to another tab | Prefix, then Shift+M |
| Rename focused agent | Prefix, then Shift+A |

### Send Hunk comments to an agent

The `Prefix`, then `C` command prompts an agent in the active workspace with
`Use the hunk-review skill. Address my comments please`. A sole agent is
prompted immediately; multiple agents open an `fzf` picker.

Install the dispatcher at `~/.config/herdr/send-hunk-comments.sh`:

```sh
#!/bin/sh
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
message="Use the hunk-review skill. Address my comments please"
workspace=${HERDR_ACTIVE_WORKSPACE_ID:?HERDR_ACTIVE_WORKSPACE_ID is required}
agent_list=$("$herdr" agent list)
agent_count=$(printf '%s\n' "$agent_list" | jq -r --arg workspace "$workspace" \
  '[.result.agents[] | select(.workspace_id == $workspace)] | length')

case "$agent_count" in
  0) exit 1 ;;
  1)
    target=$(printf '%s\n' "$agent_list" | jq -r --arg workspace "$workspace" \
      '.result.agents[] | select(.workspace_id == $workspace) | .pane_id')
    exec "$herdr" agent prompt "$target" "$message"
    ;;
  *)
    exec "$herdr" plugin pane open --plugin local.hunk-agent-picker \
      --entrypoint picker --env "HUNK_PICKER_WORKSPACE=$workspace" --focus
    ;;
esac
```

Create `~/.config/herdr/plugins/hunk-agent-picker/herdr-plugin.toml`:

```toml
id = "local.hunk-agent-picker"
name = "Hunk Agent Picker"
version = "0.1.0"
min_herdr_version = "0.8.0"
description = "Choose which agent should address comments in a live Hunk review"
platforms = ["macos", "linux"]

[[panes]]
id = "picker"
title = "Send Hunk comments"
placement = "popup"
width = "90%"
height = "90%"
command = ["/bin/sh", "-lc", "exec \"$HERDR_PLUGIN_ROOT/picker.sh\""]
```

Create `picker.sh` beside that manifest:

```sh
#!/bin/sh
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
workspace=${HUNK_PICKER_WORKSPACE:-${HERDR_WORKSPACE_ID:-}}
if [ -z "$workspace" ]; then
  workspace=$("$herdr" api snapshot | jq -r '.result.snapshot.focused_workspace_id // empty')
fi
[ -n "$workspace" ] || exit 1

target=$("$herdr" agent list | jq -r --arg workspace "$workspace" '
  .result.agents[]
  | select(.workspace_id == $workspace)
  | [.pane_id, .agent, .agent_status, .terminal_title_stripped, .foreground_cwd]
  | @tsv
' | fzf --prompt='send Hunk comments to> ' \
  --header='agent   status   title   directory' --delimiter='\t' --with-nth=2.. |
  cut -f1)

[ -n "$target" ] || exit 0
exec "$herdr" agent prompt "$target" \
  "Use the hunk-review skill. Address my comments please"
```

Register and validate it:

```sh
chmod +x ~/.config/herdr/send-hunk-comments.sh \
  ~/.config/herdr/plugins/hunk-agent-picker/picker.sh
herdr plugin link ~/.config/herdr/plugins/hunk-agent-picker --enabled
herdr config check
herdr server reload-config
```

### Hunk bridge for containerized agents

Hunk's TUI runs on the host and exposes its live review session on
`127.0.0.1:47657`. Containerized agents reach it through
`host.docker.internal`. Install this as `~/.claude/container-init.sh` and copy
it to `~/.claude/.container-init.sh`, the filename consumed by the current
`claudecc` entrypoint:

```sh
#!/usr/bin/env bash
set -euo pipefail

if ! command -v hunk &>/dev/null; then
    npm install -g --prefix "$HOME/.local" hunkdiff >/dev/null 2>&1
fi

HUNK_GW_IP="$(getent hosts host.docker.internal 2>/dev/null | awk 'NR == 1 { print $1 }' || true)"
if [ -n "$HUNK_GW_IP" ]; then
    if ! sudo iptables -C OUTPUT -p tcp --dport 47657 -d "$HUNK_GW_IP" -j ACCEPT 2>/dev/null; then
        sudo iptables -I OUTPUT 1 -p tcp --dport 47657 -d "$HUNK_GW_IP" -j ACCEPT
    fi
else
    if ! sudo iptables -C OUTPUT -p tcp --dport 47657 -j ACCEPT 2>/dev/null; then
        sudo iptables -I OUTPUT 1 -p tcp --dport 47657 -j ACCEPT
    fi
fi

touch "$CLAUDE_ENV_FILE"
grep -qxF 'export HUNK_MCP_HOST=host.docker.internal' "$CLAUDE_ENV_FILE" 2>/dev/null ||
    echo 'export HUNK_MCP_HOST=host.docker.internal' >> "$CLAUDE_ENV_FILE"
grep -qxF 'export HUNK_MCP_UNSAFE_ALLOW_REMOTE=1' "$CLAUDE_ENV_FILE" 2>/dev/null ||
    echo 'export HUNK_MCP_UNSAFE_ALLOW_REMOTE=1' >> "$CLAUDE_ENV_FILE"
```

Install it and make a physical copy of Hunk's generated review skill. Do not
symlink the skill because the container cannot follow the host Homebrew path:

```sh
chmod +x ~/.claude/container-init.sh
cp ~/.claude/container-init.sh ~/.claude/.container-init.sh
mkdir -p ~/.claude/skills/hunk-review
cp "$(hunk skill path)" ~/.claude/skills/hunk-review/SKILL.md
chmod 644 ~/.claude/skills/hunk-review/SKILL.md
```

The `HUNK_MCP_UNSAFE_ALLOW_REMOTE` flag permits the container-side CLI to use
the host-gateway address; the firewall exception remains limited to TCP port
47657 and, when resolvable, the host gateway IP. After upgrading pre-1.0 Hunk,
keep the container CLI and copied skill aligned:

```sh
# Run inside each existing container to refresh its CLI on next start.
rm -f ~/.local/bin/hunk

# Run on the host after upgrading Hunk.
cp "$(hunk skill path)" ~/.claude/skills/hunk-review/SKILL.md
```

With Hunk open on the same repository, verify inside the container:

```sh
hunk session list
hunk session comment list --repo . --type user --json
```

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

The .NET SDK was not recorded as a Homebrew package, so install the current required SDK from Microsoft. Do not rely on the Apple system Python for project tooling; install a managed Python version if a project needs it.

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
| Zoom | 7.1.5 (84650) |

## Final verification checklist

- `brew doctor` is acceptably clean
- `fish` is the login shell and `brew`, `herdr`, `hunk`, `lazygit`, `fzf`, `node`, `code`, `claude`, and `codex` resolve in a fresh terminal
- Chrome is the default browser
- Raycast opens with Command+Space
- Ghostty passes Command+1…9 through to Herdr
- `herdr config check` passes and Herdr starts at login
- Prefix+L opens LazyGit
- Prefix+C sends live Hunk comments to the selected workspace agent
- A containerized agent can run `hunk session list` while the host Hunk TUI is open
- Herdr pane-to-tab commands work
- VS Code has the three .NET extensions
- Rectangle and Scroll Reverser have their required Accessibility/Input Monitoring permissions
- Git identity, signing, SSH keys, and package registry credentials have been restored securely
