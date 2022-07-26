" Zoom / Restore window.
" inspired by https://stackoverflow.com/a/60640369/1011470
function! s:ZoomToggle(onlyRestore) abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoom_winrestcmd = ""
        let t:zoomed = 0
    elseif !a:onlyRestore
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction

command! ZoomToggle call s:ZoomToggle(v:false)
command! ZoomRestore call s:ZoomToggle(v:true)

nnoremap <C-W>z :ZoomToggle<CR>

augroup zoomtoggle
  au!
  au WinEnter * silent! :ZoomRestore
augroup END
