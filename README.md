# dotfiles

My Mac setup: Ghostty + Herdr + Fish, Neovim, AI agents (Claude Code, Codex, Hunk), and keyboard firmware for Gallium boards.

The same setup runs on both machines: a MacBook Pro M1 Pro (16 GB) at home and an M5 Max (64 GB) at work. Anything specific to one machine goes in `~/.config/fish/local.fish` or `~/.config/git/local`, which aren't in the repo, so work identity and secrets stay off the home Mac.

## Set up a machine

One script does it all. It's safe to re-run, and it moves any file it replaces to `*.bak`.

```sh
git clone https://github.com/PotterJam/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh
```

It installs Homebrew packages, links configs, installs Ioskeley Mono, sets up the AI tooling and Neovim, and makes Fish the login shell. On a Mac, open Rectangle and Scroll Reverser once, then run `./install.sh macos`. `./install.sh help` lists the individual steps. `SETUP.md` is the full rebuild guide, including what the script can't do (1Password, SSH keys, app sign-ins).

### Or let an agent do it

If something fails, or the machine is unusual, paste this into Claude Code or Codex from the repo folder:

```text
Set up this machine from this dotfiles repo. Read README.md and SETUP.md, then run ./install.sh.
If a step fails, find the cause, fix it in the repo (not just on this machine) so the script
works next time, and re-run. Don't put secrets, tokens or work identity in the repo; those go
in ~/.config/fish/local.fish and ~/.config/git/local. Finish with the SETUP.md verification
checklist and tell me what you changed and anything I still need to do by hand.
```

The script is the source of truth; the agent only runs it and repairs it.

## Windows (gaming PC)

The terminal tools run in WSL, a real Ubuntu inside Windows, using the same install script. In PowerShell:

```powershell
wsl --install -d Ubuntu   # once, then reboot and create the Ubuntu user
```

Then, in the Ubuntu terminal:

```sh
git clone https://github.com/PotterJam/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh
```

Under WSL the script also installs Homebrew for Linux, gets Claude Code and Codex from npm, and installs the font in Windows and sets it in Windows Terminal.

Use Windows Terminal (Ghostty has no Windows build). Herdr, LazyGit, Neovim, Fish, Claude Code and Codex all run inside WSL. Herdr's Ctrl+H prefix keys work there; its Command+number shortcuts are Mac-only. Neovim copies and pastes through the Windows clipboard. Mac-only apps (Raycast, Rectangle and so on) are skipped. The Gallium layout is in the keyboard firmware, so it needs no setup.

| Path | What |
|---|---|
| `home/` | Configs, linked into `$HOME` at the same paths |
| `Brewfile` | Every package and app; Mac apps are skipped on Linux and WSL |
| `install.sh` | Sets up a machine; steps `brew`, `links`, `fonts`, `ai`, `shell`, `macos` |
| `keyboard_layouts/` | Corne and Ferris (QMK), Go60 (ZMK), Gallium layout |
| `archive/` | Old Linux configs (bash, vim, emacs, i3), kept for reference |

Font: [Ioskeley Mono](https://ahatem.github.io/IoskeleyMono/). Ghostty uses the Term Nerd Font build; editors use the ligature build.

## Neovim

Simple on purpose: about 15 plugins in three files under `home/.config/nvim`. Press **Space** and wait; a menu lists every binding.

Gallium note: Vim's letters stay as they are, so `h j k l` are spread around the board. Move with the **arrows on the nav layer**, jump with **`s`**, and open things with the pickers. Nothing uses **Ctrl+H**, which is Herdr's prefix.

| Keys | Does |
|---|---|
| `Space Space` | Find file |
| `Space /` | Search the project |
| `Space e` | File explorer |
| `Space f…` | Find: `f` files, `b` buffers, `r` recent, `w` word, `s` symbols, `d` diagnostics, `k` keymaps |
| `s` then the label | Jump anywhere on screen |
| `S` | Select the surrounding syntax node, press again to grow |
| `gd` / `grr` / `gri` | Definition / references / implementation |
| `K` | Docs for the thing under the cursor |
| `Space c…` | Code: `a` action, `r` rename, `f` format, `d` line diagnostics, `h` inlay hints |
| `[d` `]d` | Previous / next diagnostic |
| `Space g…` | Git: `g` lazygit, `s` changed files, `p` preview hunk, `r` reset hunk, `b` blame |
| `]h` `[h` | Next / previous changed hunk |
| `gc` | Comment (`gcc` one line) |
| `gsa` `gsd` `gsr` | Add / delete / replace surrounding quotes or brackets |
| `Space w` `Space q` | Save / quit |
| `Space \|` `Space -` | Split right / below; Ctrl+arrows move between splits |
| `Space Tab` | Previous buffer |

Completion pops up as you type: **Enter** accepts, **Ctrl+N/Ctrl+P** or arrows move, **Ctrl+Space** opens it. Files format on save.

Languages are ready for C#, TypeScript, JavaScript, Python, Elixir, Rust, Go, Terraform, YAML, XML and SQL (PostgreSQL), plus JSON, Lua, TOML, Bash and Markdown. Each has syntax highlighting, a language server, and a formatter where one is common. To add one, edit the lists at the top of `lua/plugins/lsp.lua`. `:Mason` shows installed servers and `:Lazy` shows plugins.
