nnoremap j gj
nnoremap k gk
nnoremap 0 g0
nnoremap $ g$
set nonu
set nornu
set signcolumn=no
augroup FiletypeSettings
  autocmd!
  autocmd FileType codecompanion setlocal nonumber norelativenumber signcolumn=no
augroup END
