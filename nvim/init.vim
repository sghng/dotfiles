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

let g:python3_host_prog = "~/venvs/nvim/bin/python3"

" mappings

nnoremap <silent><Leader>bd <Cmd>bdelete<CR>

" Neovide configs

if !exists("g:neovide")
	finish
endif

let g:neovide_opacity = 0.8
let g:neovide_window_blurred = v:true
let g:neovide_cursor_vfx_mode = "sonicboom"
let g:neovide_input_macos_option_key_is_meta = "only_left"

" needs to be loaded after gruvbox-material theme
hi Normal guibg=#252423 " adapted from gruvbox material bg0

noremap <silent><D-n> <Cmd>call jobstart(["neovide"])<CR>
noremap <silent><D-w> <Cmd>q<CR>
noremap <silent><D-s> <Cmd>w<CR>
inoremap <silent><D-s> <Cmd>w<CR>

let s:guifontsize = 16
let s:guifont = "MonoLisa\\ Nerd\\ Font"
function! AdjustFontSize(amount)
	let s:guifontsize = s:guifontsize + a:amount
	execute "set guifont=" .. s:guifont .. ":h" .. s:guifontsize
endfunction

call AdjustFontSize(0)

noremap  <silent><D-=> <Cmd>call AdjustFontSize(+1)<CR>
inoremap <silent><D-=> <Cmd>call AdjustFontSize(+1)<CR>
noremap  <silent><D--> <Cmd>call AdjustFontSize(-1)<CR>
inoremap <silent><D--> <Cmd>call AdjustFontSize(-1)<CR>

noremap  <D-c>      "+y
" paste from system clipboard, somehow not working in Neovide
noremap  <D-v>      "+p
cnoremap <D-v>  <C-r>+
inoremap <D-v>  <C-r>+
