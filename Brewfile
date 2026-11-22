# brew bundle --file ./Brewfile   (./install.sh brew runs this)
# Works on macOS and on Linux, including WSL on Windows. Mac-only apps are in
# the `if OS.mac?` block; on Linux, install.sh gets Claude Code and Codex from npm.

tap "hashicorp/tap"

# Shell and terminal workflow
brew "fish"
brew "fzf"
brew "herdr"
brew "modem-dev/tap/hunk"
brew "lazygit"
brew "jq"
brew "socat"

# Neovim and the tools its plugins call
brew "neovim"
brew "ripgrep"
brew "fd"
brew "tree-sitter-cli"

# Language toolchains (Neovim's language servers need them too)
brew "node"
brew "go"
brew "rustup"
brew "uv"
brew "elixir"
brew "hashicorp/tap/terraform"
brew "podman"
brew "dotnet" unless OS.mac?

if OS.mac?
  # AI
  cask "claude"
  cask "claude-code"
  cask "codex"

  # Apps
  cask "1password"
  cask "dotnet-sdk"
  cask "ghostty"
  cask "google-chrome"
  cask "notion"
  cask "notion-calendar"
  cask "raycast"
  cask "rectangle"
  cask "scroll-reverser"
  cask "slack"
  cask "spotify"
  cask "visual-studio-code"
  cask "zoom"
end
