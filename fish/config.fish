if status is-interactive
    set fish_greeting ""
    cursor-agent shell-integration fish
    starship init fish | source
end

# PATH
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.4.0/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.local/bin

# ENV
set -x EDITOR nvim
set -x BAT_THEME gruvbox-dark
set -x MANPAGER 'nvim -M +Man!'
set -x DOTS $HOME/dev/dotfiles
set -x UV_PYTHON 3.13
set -x CSPELL_DEFAULT_CONFIG_PATH $HOME/.config/cspell.config.yaml

# ABBR
abbr -a vi nvim
abbr -a ls lsd
abbr -a ll lsd -l
abbr -a la lsd -a
abbr -a du dust
abbr -a df duf
abbr -a cat bat
abbr -a dots "cd $DOTS"
abbr -a t "tmux attach -t base; or tmux new -s base"

# FUNC
function vast # nvim as a pager
    nvim -M +"nnoremap q :qa!<CR>" +"set nonumber norelativenumber signcolumn=no" -
end

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
set -gx MAMBA_EXE /opt/homebrew/opt/micromamba/bin/mamba
set -gx MAMBA_ROOT_PREFIX /Users/sghuang/mamba
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
