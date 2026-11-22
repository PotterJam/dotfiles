# Mac setup and rebuild guide

Last inventoried: 12 August 2026

This is a portable record of the useful software and preferences on this Mac. It intentionally excludes passwords, tokens, SSH keys, application databases, logs, window positions, and other transient state.

## Machine baseline

- Work: MacBook Pro (`Mac17,6`), Apple M5 Max, 64 GB RAM (this inventory was taken on it)
- Home: MacBook Pro, Apple M1 Pro, 16 GB RAM
- Apple Silicon (`arm64`)
- macOS 26.5.1 at the time of inventory
- System keyboard input source: U.S.
- Physical keyboard layout: Gallium
- Login shell: Fish (`/opt/homebrew/bin/fish`)
- Default browser: Google Chrome
- Appearance follows the macOS default; Herdr switches Catppuccin themes automatically

Do not try to reproduce the exact OS or app versions below unless debugging a regression. Install current stable releases instead.

## Rebuild order

1. Complete macOS updates, then sign in to 1Password before restoring credentials or developer keys.
2. Install the Xcode command-line tools and Homebrew:

   ```sh
   xcode-select --install
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

3. Clone this repo to `~/dotfiles` and run `./install.sh`. It installs the Brewfile, links configs, installs Ioskeley Mono, sets up AI tooling and Neovim, and makes Fish the login shell.
4. Open Rectangle and Scroll Reverser once, quit them, then run `./install.sh macos` for the Dock, Rectangle and Scroll Reverser preferences.
5. Put Git identity and signing in `~/.config/git/local`, and machine-only Fish settings or secrets in `~/.config/fish/local.fish`. Neither is in the repo.
6. Fully quit and reopen Ghostty. Sign in to apps and restore SSH keys from 1Password.

Install current stable releases; the versions at the end of this file are an audit trail, not pins.

## Where each config lives

Everything under `home/` is linked into `$HOME` at the same path by `./install.sh links`. Edit it in the repo.

| Tool | Repo file | Notes |
|---|---|---|
| Fish | `home/.config/fish/config.fish` | Homebrew env, `EDITOR=nvim`, `v` and `lg` abbreviations |
| Git | `home/.config/git/config` | Aliases and defaults; includes `~/.config/git/local` |
| Ghostty | `home/.config/ghostty/config.ghostty` | Ioskeley font, Catppuccin, Command+1…9 left to Herdr. `install.sh` moves the old `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` aside so this one wins |
| Herdr | `home/.config/herdr/` | `config.toml`, `send-hunk-comments.sh`, `plugins/hunk-agent-picker/` |
| Claude Code | `home/.claude/container-init.sh` | Hunk bridge for containerised agents |
| Neovim | `home/.config/nvim/` | See README |

`./install.sh fonts` installs Ioskeley Mono to `~/Library/Fonts`: the ligature build for editors and the Term Nerd Font build (strict cell widths, icons) for the terminal. It also points VS Code's editor and terminal at them when its `settings.json` is plain JSON.

## Herdr

Running `herdr` starts its background server if it isn't already running (Homebrew's formula has no `brew services` entry). After editing its config:

```sh
herdr config check
herdr server reload-config
```

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

Prefix, then C prompts an agent in the active workspace with `Use the hunk-review skill. Address my comments please`. A sole agent is prompted immediately; several open an `fzf` picker (the `hunk-agent-picker` plugin, which `./install.sh ai` links).

## Hunk bridge for containerised agents

Hunk's TUI runs on the host and exposes its live review session on `127.0.0.1:47657`. Containerised agents reach it through `host.docker.internal`. `./install.sh ai` copies `container-init.sh` to `~/.claude/.container-init.sh`, the name the `claudecc` entrypoint reads, and copies Hunk's review skill to `~/.claude/skills/hunk-review/SKILL.md`. Both are real copies, not links, because the container cannot follow host paths.

The `HUNK_MCP_UNSAFE_ALLOW_REMOTE` flag permits the container-side CLI to use the host-gateway address; the firewall exception remains limited to TCP port 47657 and, when resolvable, the host gateway IP. After upgrading pre-1.0 Hunk, keep the container CLI and copied skill aligned:

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

`./install.sh macos` restores the exact values; run it after installing and quitting Rectangle.

Because Gallium changes the produced characters, verify these shortcuts by physical key position after restoring them.

### Scroll Reverser

- Scroll reversing enabled globally
- Trackpad reversing disabled
- Discrete-scroll options shown

`./install.sh macos` restores these; run it after installing and quitting the app.

Grant Accessibility/Input Monitoring permissions again when prompted.

## macOS preferences worth restoring

- Dock position: right
- Default browser: Google Chrome
- Keyboard input source: U.S.; Gallium is provided by the physical keyboard/firmware setup rather than a macOS input source
- Spotlight Command+Space shortcuts disabled so Raycast can own Command+Space
- Most inspected keyboard repeat, Finder, screenshot, appearance, and Dock auto-hide settings were left at macOS defaults

`./install.sh macos` sets the Dock position.

Dock item ordering is easiest to restore manually.

## Runtimes and containers

Observed versions, for reference only:

- Node.js 26.7.0, npm 11.19.0 (Homebrew)
- .NET SDK 10.0.302
- Apple-provided Python 3.9.6
- Podman client 6.0.2; no Podman machine was listed
- Apple Git 2.50.1
- Fish 4.8.1

The Brewfile now installs the .NET SDK (`dotnet-sdk` cask), Go, Rust (`rustup`), Elixir, Terraform and `uv`; Neovim's language servers need them. Use `uv` for Python rather than the Apple system Python.

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
- `herdr config check` passes and `herdr status` shows the server running
- Prefix+L opens LazyGit
- Prefix+C sends live Hunk comments to the selected workspace agent
- A containerized agent can run `hunk session list` while the host Hunk TUI is open
- Herdr pane-to-tab commands work
- VS Code has the three .NET extensions
- Rectangle and Scroll Reverser have their required Accessibility/Input Monitoring permissions
- Git identity, signing, SSH keys, and package registry credentials have been restored securely
- Ghostty renders in Ioskeley Mono (`ghostty +list-fonts | grep -i ioskeley`)
- `nvim` opens without errors and `:checkhealth vim.lsp` lists servers on a C# or TypeScript file
