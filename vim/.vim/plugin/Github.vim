let g:hasGithub = executable('gh') ? 1 : 0

if g:hasGithub == 1
  function! s:copyGithubBrowseUrl()
      let l:current_file_path = expand('%')
      let l:current_line = line('.')
      let l:command =  'gh browse -c -n ' . l:current_file_path . ':' . l:current_line
      let l:url = system(l:command)
      let @+=l:url
      echo 'Copied GH browse url to clipboard.'
  endfunction

  command! CopyGithubBrowseUrl :call s:copyGithubBrowseUrl()

  nnoremap <silent> <Leader>ghb :CopyGithubBrowseUrl<CR>
endif

