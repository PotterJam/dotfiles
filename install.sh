#!/usr/bin/env bash
# Set up this machine from the dotfiles repo.
#
#   ./install.sh            link configs, install fonts, set up AI tooling
#   ./install.sh brew       install everything in the Brewfile
#   ./install.sh links      link every file under home/ into $HOME
#   ./install.sh fonts      install Ioskeley Mono (editor + terminal builds)
#   ./install.sh ai         Claude container init and the Hunk review skill
#   ./install.sh macos      Dock, Rectangle and Scroll Reverser preferences
#
# Safe to re-run. Existing files that would be replaced are moved to *.bak.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
IOSKELEY_VERSION="v2.2.0"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

link() { # link SOURCE TARGET
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak"; echo "   moved old $dst to $dst.bak"; fi
  ln -s "$src" "$dst"
  echo "   $dst"
}

cmd_brew() {
  say "Homebrew packages"
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  brew bundle --file "$DOTFILES/Brewfile"
  rustup-init -y --no-modify-path >/dev/null 2>&1 || true
  brew services start herdr || true
}

cmd_links() {
  say "Linking configs into $HOME"
  # Neovim is linked as one directory so new plugin files appear without relinking.
  link "$DOTFILES/home/.config/nvim" "$HOME/.config/nvim"
  (cd "$DOTFILES/home" && find . -type f -not -path './.config/nvim/*') | while read -r f; do
    link "$DOTFILES/home/${f#./}" "$HOME/${f#./}"
  done
  # Ghostty on macOS also reads this file, after ~/.config/ghostty; retire it so the repo copy wins.
  local old="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
  if [ -f "$old" ] && [ ! -L "$old" ]; then mv "$old" "$old.bak"; echo "   moved old $old to .bak"; fi
  touch "$HOME/.config/git/local" # identity and signing go here, outside the repo
}

cmd_fonts() {
  say "Ioskeley Mono $IOSKELEY_VERSION"
  local dir tmp
  if [ "$(uname)" = Darwin ]; then dir="$HOME/Library/Fonts"; else dir="$HOME/.local/share/fonts/IoskeleyMono"; fi
  mkdir -p "$dir"
  tmp="$(mktemp -d)"
  # IoskeleyMono: ligatures, for VS Code and other editors.
  # IoskeleyMono-Term-NerdFont: strict cell widths plus icons, for Ghostty and Neovim.
  for pkg in IoskeleyMono IoskeleyMono-Term-NerdFont; do
    curl -fsSL -o "$tmp/$pkg.zip" "https://github.com/ahatem/IoskeleyMono/releases/download/$IOSKELEY_VERSION/$pkg.zip"
    unzip -qo "$tmp/$pkg.zip" -d "$tmp/$pkg"
  done
  find "$tmp/IoskeleyMono/Normal/Unhinted" "$tmp/IoskeleyMono-Term-NerdFont/Normal" \
    -name '*.ttf' -not -name '*NerdFontMono-*' -exec cp {} "$dir/" \;
  rm -rf "$tmp"
  command -v fc-cache >/dev/null && fc-cache -f "$dir" >/dev/null || true
  echo "   installed to $dir"

  # VS Code: point the editor and its terminal at Ioskeley if settings are plain JSON.
  local code="$HOME/Library/Application Support/Code/User/settings.json"
  if [ -f "$code" ] && jq empty "$code" 2>/dev/null; then
    jq '. + {"editor.fontFamily": "'"'"'Ioskeley Mono'"'"', monospace",
             "editor.fontLigatures": true,
             "terminal.integrated.fontFamily": "'"'"'IoskeleyMonoTerm Nerd Font'"'"'"}' \
      "$code" > "$code.tmp" && mv "$code.tmp" "$code"
    echo "   VS Code now uses Ioskeley Mono"
  fi
}

cmd_ai() {
  say "AI tooling"
  # The claudecc entrypoint reads the dotted name, and containers can't follow
  # symlinks into the host, so both are real copies.
  mkdir -p "$HOME/.claude/skills/hunk-review"
  cp "$DOTFILES/home/.claude/container-init.sh" "$HOME/.claude/.container-init.sh"
  if command -v hunk >/dev/null; then
    cp "$(hunk skill path)" "$HOME/.claude/skills/hunk-review/SKILL.md"
    chmod 644 "$HOME/.claude/skills/hunk-review/SKILL.md"
    echo "   Hunk review skill copied"
  fi
  if command -v herdr >/dev/null; then
    herdr plugin link "$HOME/.config/herdr/plugins/hunk-agent-picker" --enabled || true
    herdr config check
  fi
  if command -v nvim >/dev/null; then
    say "Neovim plugins, parsers and language servers (first run takes a few minutes)"
    nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
  fi
}

cmd_macos() {
  say "macOS preferences"
  defaults write com.apple.dock orientation -string right && killall Dock
  defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
  defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
  defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
  defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
  defaults write com.knollsoft.Rectangle toggleTodo -dict keyCode -int 11 modifierFlags -int 786432
  defaults write com.knollsoft.Rectangle reflowTodo -dict keyCode -int 45 modifierFlags -int 786432
  defaults write com.pilotmoon.scroll-reverser InvertScrollingOn -bool true
  defaults write com.pilotmoon.scroll-reverser ReverseTrackpad -bool false
  defaults write com.pilotmoon.scroll-reverser ShowDiscreteScrollOptions -bool true
}

case "${1:-all}" in
  all) cmd_links; cmd_fonts; cmd_ai ;;
  brew|links|fonts|ai|macos) "cmd_$1" ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
