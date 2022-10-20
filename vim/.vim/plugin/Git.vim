def s:GitBlameLineFunc()
    var popup_win = printf("git -C %s blame -s -L %s,%s -- %s | head -c 8", expand('%:h'), line('.'), line('.'), expand('%:p'))

        ->system()
        ->printf("git -C " .. expand('%:h') .. " log --stat -1 %s")
        ->system()
        ->split("\n")
        ->popup_atcursor({ "padding": [0, 1, 1, 1] })
    call setbufvar(winbufnr(popup_win), '&filetype', 'git')
enddef
nnoremap <silent><leader>bl :call <SID>GitBlameLineFunc()<CR>
