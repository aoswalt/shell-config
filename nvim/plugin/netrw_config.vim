let g:netrw_altfile = 1   "allow <c-6> to go to the previously edited file
let g:netrw_preview = 1   "open preview window in a vertical split
"
" netrw splits
noremap <silent> <leader>x :Vexplore!<CR>:wincmd =<CR>
noremap <silent> <leader>X :Sexplore<CR>:wincmd =<CR>
