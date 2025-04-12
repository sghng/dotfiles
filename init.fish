# script used to initialize the environment

set -l d (realpath (dirname (status -f)))

for c in .zshrc .zprofile .tmux.conf .wezterm.lua
    ln -sf $d/$c ~
end

for c in ghostty kitty rio nvim neovide starship.toml
    ln -sf $d/$c ~/.config/
end

dash -c "ln -sf $d/fish ~/.config" # fish can't handle itself

mkdir -p ~/.config/alacritty
ln -sf $d/alacritty.toml ~/.config/alacritty/

cd $HOME/.config/rio
git clone --depth=1 -b master https://github.com/libretro/slang-shaders.git

touch ~/.hushlogin
