#!/usr/bin/env fish
# script used to initialize the environment

# $d is the dir for dotfiles
set -l d (realpath (dirname (status -f)))

# these go into home dir
for c in .ipython .mambarc .tmux.conf .wezterm.lua
    ln -sf $d/$c ~
end

# these go into config dir
for c in alacritty cspell.config.yaml ghostty kitty neovide nvim rio starship.toml
    ln -sf $d/$c ~/.config/
end

set -l VALE_CONFIG_PATH "$HOME/Library/Application Support/vale/"
cd $VALE_CONFIG_PATH
ln -sf $d/.vale.ini .
vale sync # must be executed inside VALE_CONFIG_PATH

cd ~/.config/rio
curl -L https://github.com/libretro/slang-shaders/archive/master.tar.gz |
    tar -xz --strip-components=1 -C shaders

touch ~/.hushlogin

dash -c "ln -sf $d/fish ~/.config" # fish can't handle itself
