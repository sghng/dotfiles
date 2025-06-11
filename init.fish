# script used to initialize the environment

set -l d (realpath (dirname (status -f)))

for c in .zshrc .zprofile .tmux.conf .wezterm.lua
    ln -sf $d/$c ~
end

for c in ghostty kitty alacritty rio nvim neovide starship.toml
    ln -sf $d/$c ~/.config/
end

set -l VALE_CONFIG_PATH "~/Library/Application Support/vale/"
cd VALE_CONFIG_PATH
ln -sf $d/.vale.ini .
vale sync # must be executed inside VALE_CONFIG_PATH

cd ~/.config/rio
curl -L https://github.com/libretro/slang-shaders/archive/master.tar.gz |
    tar -xz --strip-components=1

touch ~/.hushlogin

dash -c "ln -sf $d/fish ~/.config" # fish can't handle itself
