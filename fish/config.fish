set -x DOTS $HOME/dev/dotfiles

if status is-interactive
    set fish_greeting ""
    set -x MANPAGER 'nvim -M +Man!'
    set -x EDITOR nvim
    set -x BAT_THEME gruvbox-dark
    set HOMEBREW_NO_ENV_HINTS 1

    cursor-agent shell-integration fish
    starship init fish | source

    alias clear='clear -x' # clear should retain history

    abbr -a vi nvim
    abbr -a ls lsd
    abbr -a ll lsd -l
    abbr -a la lsd -a
    abbr -a du dust
    abbr -a df duf
    abbr -a dots "cd $DOTS"
    abbr -a t "tmux attach -t base; or tmux new -s base"

    function vast # nvim as a pager
        col -bx | nvim -M +"nnoremap q :qa!<CR>" +"set nonumber norelativenumber signcolumn=no" -
    end
end

# PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.4.0/bin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.ghcup/bin
fish_add_path /opt/homebrew/opt/postgresql@18/bin

# FUNCTIONS
function pr_merge -d "Squash merge a branch like a PR"
    set -l branch $argv[1]
    git merge --squash "$branch"
    if test $status -ne 0
        return 1
    end
    begin
        echo "$branch"
        echo ""
        git log --pretty=format:"* %s%n" HEAD.."$branch"
    end | git commit -e -F -
end

# ENV
set -x CSPELL_DEFAULT_CONFIG_PATH $HOME/.config/cspell.config.yaml

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
set -gx MAMBA_EXE /opt/homebrew/opt/micromamba/bin/mamba
set -gx MAMBA_ROOT_PREFIX /Users/sghuang/mamba
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
