setlocal fdm=syntax
" start with folding turned off, can turn on with zc or zC
setlocal nofoldenable

setlocal equalprg=jq\ .
setlocal formatprg=jq\ .

" TODO: it would be cool if this could take a range
function! s:tryJq() abort
  :silent %!jq .
  if v:shell_error != 0
    echo 'jq failed: ' . v:shell_error
    undo
  endif
endfunction

command! <buffer> TryJq call s:tryJq()
nnoremap <buffer> <leader>= :TryJq<CR>
