function! s:InsertBaseName()
  let l:text=expand('%:t:r')
  execute "normal! i\<C-r>\<C-r>=l:text\<CR>\<Esc>"
endfunction

command! InsertBaseName :call s:InsertBaseName()

nnoremap <silent><leader>name :InsertBaseName<CR>
