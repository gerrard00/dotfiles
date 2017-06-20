" wrap
setlocal wrap linebreak nolist

" move by display lines
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> ^ g^
noremap  <buffer> <silent> $ g$
inoremap <buffer> <silent> <C-o>k <C-o>gk
inoremap <buffer> <silent> <C-o>j <C-o>gj
inoremap <buffer> <silent> <C-o>^ <C-o>g^
inoremap <buffer> <silent> <C-o>$ <C-o>g$

" turn on spell checking
setlocal spell
