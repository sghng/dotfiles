" leader keys set before Lazy to avoid confusions
let mapleader=" "
" some plugins expect this lazy config path specifically
lua require("config.lazy")

" custom configs come later to override plugin defaults

set colorcolumn=81,101,121
set mouse=a
set signcolumn=yes:2

" will be overridden by vim-sleuth
set expandtab
set shiftwidth=4
set tabstop=4

let g:python3_host_prog = "~/venvs/nvim/bin/python"

" mappings

nnoremap <silent><Leader>bd :bdelete<CR>

" Neovide configs

if !exists("g:neovide")
	finish
endif

let g:neovide_opacity = 0.8
let g:neovide_window_blurred = v:true
let g:neovide_cursor_vfx_mode = "sonicboom"

" needs to be loaded after gruvbox-material theme
hi Normal guibg=#252423 " adapted from gruvbox material bg0

" paste from system clipboard, somehow not working in Neovide
nnoremap <D-v>      "+p
vnoremap <D-v>      "+p
inoremap <D-v>  <C-r>+
