# Homebrew: Apple Silicon on the Mac, /home/linuxbrew on Linux and WSL.
for brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        eval ($brew shellenv fish)
        break
    end
end

# Homebrew's .NET on Linux needs this so tools such as the C# language server find it.
if set -q HOMEBREW_PREFIX; and test -d $HOMEBREW_PREFIX/opt/dotnet/libexec
    set --global --export DOTNET_ROOT $HOMEBREW_PREFIX/opt/dotnet/libexec
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
