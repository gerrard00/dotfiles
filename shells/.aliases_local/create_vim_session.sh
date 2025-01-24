#!/bin/bash

create_vim_session() {
    local session_file="Session.vim"
    local first_file=""

    # Create or overwrite Session.vim with initial content
    cat > "$session_file" << EOL
let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd $(pwd)
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
EOL

    # Read filenames from stdin and add them to the session
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "badd +1 $file" >> "$session_file"
            # Store the first file for later use
            if [ -z "$first_file" ]; then
                first_file="$file"
            fi
        else
            echo "Warning: File '$file' not found. Skipping." >&2
        fi
    done

    # If no valid files were found, exit with an error
    if [ -z "$first_file" ]; then
        echo "Error: No valid files were provided." >&2
        return 1
    fi

    # Finish the session file
    cat >> "$session_file" << EOL
\$argadd ${first_file}
edit ${first_file}
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 24) / 49)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &g:so = s:so_save | let &g:siso = s:siso_save
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
tabnext 1
EOL

    echo "Session.vim has been created with the provided files." >&2
    return 0
}