# Homebrew on Apple Silicon: binaries, manuals and environment.
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv fish)
end

# Keep interactive terminal apps such as lazygit in colour.
set --erase NO_COLOR

fish_add_path --global ~/.local/bin ~/.dotnet/tools ~/.cargo/bin ~/go/bin

set --global --export EDITOR nvim
set --global --export VISUAL nvim
set --global --export MANPAGER "nvim +Man!"

if status is-interactive
    abbr --add v nvim
    abbr --add lg lazygit
end

# Machine-specific settings and secrets stay out of the repo.
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
