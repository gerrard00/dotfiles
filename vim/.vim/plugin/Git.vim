let g:hasGithub = executable('gh') ? 1 : 0

if g:hasGithub == 1
  function! CopyGithubBrowseUrl()
      let l:current_file_path = expand('%')
      let l:current_line = line('.')

      let l:branch_command = 'git branch --show-current'
      let l:branch_name = system(l:branch_command)
      let l:clean_branch_name = substitute(l:branch_name, '\n\+$', '', '')
      let l:command =  'gh browse -b ' . l:clean_branch_name . ' ' . l:current_file_path . ':' . l:current_line . ' -n '
      let l:url = system(l:command)
      let @+=l:url
      echo 'Copied GH browse url to clipboard.'
  endfunction

  command! CopyGithubBrowseUrl call CopyGithubBrowseUrl()

  nnoremap <silent> <Leader>ghb :CopyGithubBrowseUrl<CR>
endif
