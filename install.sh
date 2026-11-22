#!/usr/bin/env bash
# Set up this machine from the dotfiles repo.
#
#   ./install.sh            everything below except macos, in order
#   ./install.sh brew       install everything in the Brewfile
#   ./install.sh links      link every file under home/ into $HOME
#   ./install.sh fonts      install Ioskeley Mono (editor + terminal builds)
#   ./install.sh ai         Claude container init and the Hunk review skill
#   ./install.sh shell      make Fish the login shell
#   ./install.sh macos      Dock, Rectangle and Scroll Reverser preferences
#                           (run after opening and quitting those apps once)
#
# Works on macOS and on Linux, including WSL on Windows. Under WSL, `brew`
# installs Homebrew if needed and `fonts` also installs the font into Windows
# and points Windows Terminal at it.
#
# Safe to re-run. Existing files that would be replaced are moved to *.bak.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
IOSKELEY_VERSION="v2.2.0"

is_mac() { [ "$(uname)" = Darwin ]; }
is_wsl() { grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }

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
  if ! is_mac && [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    say "Installing Homebrew for Linux (asks for your sudo password)"
    sudo apt-get update -qq
    sudo apt-get install -y -qq build-essential procps curl file git unzip
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if ! command -v brew >/dev/null; then
    for b in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
      [ -x "$b" ] && eval "$("$b" shellenv)" && break
    done
  fi
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  # Homebrew 7 only loads third-party formulae you have trusted; trust just these two.
  if brew trust --help >/dev/null 2>&1; then
    brew trust --formula hashicorp/tap/terraform modem-dev/tap/hunk
  fi
  brew bundle --file "$DOTFILES/Brewfile"
  rustup-init -y --no-modify-path >/dev/null 2>&1 || true
  if ! is_mac; then
    say "Claude Code and Codex (npm; the Mac gets them as casks)"
    npm install -g @anthropic-ai/claude-code @openai/codex
  fi
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
  if is_mac; then dir="$HOME/Library/Fonts"; else dir="$HOME/.local/share/fonts/IoskeleyMono"; fi
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

  if is_mac; then
    set_vscode_font "$HOME/Library/Application Support/Code/User/settings.json"
  elif is_wsl; then
    windows_fonts "$dir"
  fi
}

# Point VS Code's editor and terminal at Ioskeley, if its settings are plain JSON.
set_vscode_font() {
  local code="$1"
  [ -f "$code" ] && jq empty "$code" 2>/dev/null || return 0
  jq '. + {"editor.fontFamily": "'"'"'Ioskeley Mono'"'"', monospace",
           "editor.fontLigatures": true,
           "terminal.integrated.fontFamily": "'"'"'IoskeleyMonoTerm Nerd Font'"'"'"}' \
    "$code" > "$code.tmp" && mv "$code.tmp" "$code"
  echo "   VS Code now uses Ioskeley Mono"
}

# WSL: the terminal window is a Windows app, so the font has to be installed in Windows.
windows_fonts() {
  local src="$1" localappdata wt
  localappdata="$(wslpath "$(powershell.exe -NoProfile -c '$env:LOCALAPPDATA' | tr -d '\r')")"
  local stage="$localappdata/Temp/ioskeley"
  mkdir -p "$stage" && cp "$src"/*.ttf "$stage/"
  # Per-user install: copy into the user font folder and register each file.
  powershell.exe -NoProfile -c "
    \$dest = \"\$env:LOCALAPPDATA\\Microsoft\\Windows\\Fonts\"
    New-Item -ItemType Directory -Force \$dest | Out-Null
    \$reg = 'HKCU:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts'
    Get-ChildItem '$(wslpath -w "$stage")' -Filter *.ttf | ForEach-Object {
      Copy-Item \$_.FullName \$dest -Force
      Set-ItemProperty \$reg \"\$(\$_.BaseName) (TrueType)\" (Join-Path \$dest \$_.Name)
    }" >/dev/null
  rm -rf "$stage"
  echo "   installed in Windows (restart Windows Terminal to see it)"

  wt="$localappdata/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  if [ -f "$wt" ] && jq empty "$wt" 2>/dev/null; then
    jq '.profiles.defaults.font.face = "IoskeleyMonoTerm Nerd Font"' "$wt" > "$wt.tmp" && mv "$wt.tmp" "$wt"
    echo "   Windows Terminal now uses IoskeleyMonoTerm Nerd Font"
  else
    echo "   Set Windows Terminal's font by hand: Settings > Defaults > Appearance > IoskeleyMonoTerm Nerd Font"
  fi
  set_vscode_font "$(wslpath "$(powershell.exe -NoProfile -c '$env:APPDATA' | tr -d '\r')")/Code/User/settings.json"
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

cmd_shell() {
  local fish
  fish="$(command -v fish || true)"
  [ -n "$fish" ] || { echo "   fish isn't installed; run ./install.sh brew first"; return 0; }
  [ "${SHELL:-}" = "$fish" ] && return 0
  say "Making Fish the login shell (asks for your password)"
  grep -qxF "$fish" /etc/shells || echo "$fish" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$fish"
}

cmd_macos() {
  is_mac || { echo "macos: only on a Mac"; return 0; }
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
  all) cmd_brew; cmd_links; cmd_fonts; cmd_ai; cmd_shell
       say "Done. Open a new terminal. On a Mac, also run ./install.sh macos once the apps have been opened." ;;
  brew|links|fonts|ai|shell|macos) "cmd_$1" ;;
  help|-h|--help) sed -n '2,17p' "$0" ;;
  *) sed -n '2,17p' "$0"; exit 1 ;;
esac
