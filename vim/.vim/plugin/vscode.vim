" function! s:launchCode() abort
"   :silent %!code .
"   if v:shell_error != 0
"     echo 'jq failed: ' . v:shell_error
"     undo
"   endif
" endfunction

" command! -buffer TryJq call s:tryJq()
nnoremap <buffer> <leader>code :Dispatch code %<cr>

