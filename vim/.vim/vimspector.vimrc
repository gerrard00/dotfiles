
let s:mapped = {}

nmap <silent> <F5>         <Plug>VimspectorContinue
nmap <silent> <F9>         <Plug>VimspectorToggleBreakpoint
" nmap <silent> <Leader>reset    <Plug>VimspectorReset
" nmap <Leader>exit    <Plug>VimspectorReset
nmap <Leader>x    :call vimspector#Reset()<CR>

function! s:OnJumpToFrame() abort
  if has_key( s:mapped, string( bufnr() ) )
    return
  endif

  nmap <silent> <buffer> <S-F5>       <Plug>VimspectorStop
  nmap <silent> <buffer> <Leader>stop       <Plug>VimspectorStop
  nmap <silent> <buffer> <C-S-F5>     <Plug>VimspectorRestart
  nmap <silent> <buffer> <F6>         <Plug>VimspectorPause
  nmap <silent> <buffer> <S-F8>       <Plug>VimspectorJumpToPreviousBreakpoint
  nmap <silent> <buffer> <S-F9>       <Plug>VimspectorAddFunctionBreakpoint
  nmap <silent> <buffer> <F10>        <Plug>VimspectorStepOver
  nmap <silent> <buffer> <F11>        <Plug>VimspectorStepInto
  nmap <silent> <buffer> <S-F11>      <Plug>VimspectorStepOut
  nmap <silent> <buffer> <M-8>        <Plug>VimspectorDisassemble
  xmap <silent> <buffer> <M-8>        <Plug>VimspectorDisassemble

  nmap <silent> <Leader>stop    <Plug>VimspectorStop

  let s:mapped[ string( bufnr() ) ] = { 'modifiable': &modifiable }

  setlocal nomodifiable

endfunction

function! s:OnDebugEnd() abort

  let original_buf = bufnr()
  let hidden = &hidden
  augroup VimspectorSwapExists
    au!
    autocmd SwapExists * let v:swapchoice='o'
  augroup END

  try
    set hidden
    for bufnr in keys( s:mapped )
      try
        execute 'buffer' bufnr

        nunmap <silent> <buffer> <S-F5>
        nunmap <silent> <buffer> <Leader>stop
        nunmap <silent> <buffer> <C-S-F5>
        nunmap <silent> <buffer> <F6>
        nunmap <silent> <buffer> <F8>
        nunmap <silent> <buffer> <S-F8>
        nunmap <silent> <buffer> <S-F9>
        nunmap <silent> <buffer> <F10>
        nunmap <silent> <buffer> <F11>
        nunmap <silent> <buffer> <S-F11>
        nunmap <silent> <buffer> <M-8>
        xunmap <silent> <buffer> <M-8>

        nunmap <silent> <Leader>stop

        let &l:modifiable = s:mapped[ bufnr ][ 'modifiable' ]
      endtry
    endfor
  finally
    execute 'noautocmd buffer' original_buf
    let &hidden = hidden
  endtry

  au! VimspectorSwapExists

  let s:mapped = {}
endfunction

augroup TestCustomMappings
  au!
  autocmd User VimspectorJumpedToFrame call s:OnJumpToFrame()
  autocmd User VimspectorDebugEnded ++nested call s:OnDebugEnd()
augroup END
