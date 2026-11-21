# dotfiles

My Mac setup: Ghostty + Herdr + Fish, Neovim, AI agents (Claude Code, Codex, Hunk), and keyboard firmware for Gallium boards.

The same setup runs on both machines: a MacBook Pro M1 Pro (16 GB) at home and an M5 Max (64 GB) at work. Anything specific to one machine goes in `~/.config/fish/local.fish` or `~/.config/git/local`, which aren't in the repo, so work identity and secrets stay off the home Mac.

```sh
git clone https://github.com/PotterJam/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh brew   # Brewfile
./install.sh        # link configs, Ioskeley Mono, AI tooling, Neovim plugins
```

`SETUP.md` is the full rebuild guide.

| Path | What |
|---|---|
| `home/` | Configs, linked into `$HOME` at the same paths |
| `Brewfile` | Every package and app |
| `install.sh` | `brew`, `links`, `fonts`, `ai`, `macos` steps |
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
