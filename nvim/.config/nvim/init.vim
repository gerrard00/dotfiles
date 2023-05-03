lua require('plugins')

" Only need to enable this plugin temporarily, then run
" TmuxlineSnapshot to create a new file that can be sourced
" from .tmux.conf
" Plug 'edkolev/tmuxline.vim'

filetype plugin indent on    " required

filetype on

" https://stackoverflow.com/a/33380495/1011470
if !exists("g:syntax_on")
    syntax enable
endif

set tabstop=2 shiftwidth=2 expandtab

"turn off word wrap
set nowrap

set number

" airline config
let g:airline_powerline_fonts = 1
" only show name part of file path
let g:airline#extensions# = ':t'
let g:airline#extensions#tabline#enabled = 1
" only show name part of file path
let g:airline#extensions#tabline#fnamemod = ':t'
" only show tabline if multiple buffers are open
let g:airline#extensions#tabline#buffer_min_count = 2
" hide tab type on right hand side
let g:airline#extensions#tabline#show_tab_type = 0
" truncate git branch name
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline#extensions#branch#enabled = 1

" toggle paste mode
set pastetoggle=<F2>

" setup colors
colorscheme nord
set cursorline
set cursorlineopt=number
highlight Visual cterm=bold gui=bold

" do I need this in neovim?
let $vimrc_local = expand('~/.vimrc.local')
if filereadable($vimrc_local)
  source $vimrc_local
endif

"transparent background (note has to go after local file,
"as that might set colors
"hi Normal ctermbg=none
hi LineNr ctermbg=none guibg=bg

"NERDTree
"show hidden files
let NERDTreeShowHidden=1

"toggle display of nerdtree: http://stackoverflow.com/a/10417725/1011470
silent! nmap <F3> :NERDTreeToggle<CR>
silent! map <F4> :NERDTreeFind<CR>
let g:NERDTreeMapPreview="<F4>"

" have vim better whitespace work on save
let g:strip_whitespace_on_save = 1
let g:better_whitespace_enabled = 1
let g:strip_whitespace_confirm=0

" Don't show mode in status line
set noshowmode

" use local tags file if present
set tags+=tags;

" vim-node split should use vertical split
autocmd User Node
      \ if &filetype == "javascript" |
      \   nmap <buffer> <C-w>f <Plug>NodeVSplitGotoFile <bar> <C-w>r |
      \ endif

" new line w/o insert
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

" jk for escape
inoremap jk <esc>

" autoformat xml w/ tidy
au FileType xml setlocal equalprg=tidy\ -xml\ -i\ -w\ 0\ -q\ -\ 2>\/dev\/null\ \|\|\ true

" turn on matchit, so we can match markup tags
runtime macros/matchit.vim

" only conceal characters in normal and command
let g:indentLine_concealcursor = 'nc'

" enter iso date
nnoremap <Leader>date a<C-R>=strftime('%FT%T%z')<CR><Esc>
inoremap <Leader>date <C-R>=strftime('%FT%T%z')<CR>
vnoremap <Leader>date c<C-R>=strftime('%FT%T%z')<CR><Esc>

" simple closing braces, etc.
" the plugins didn't work with my style
" note: <C-G>u in insert mode breaks the undo sequence
imap {}  {<CR>}<C-o>O<C-G>u
imap (); ();<C-o>h

" my mocha only plugin mapping
nnoremap <Leader>mo :MochaOnlyToggle<CR>

" setup shortcuts for moving through buffers
nnoremap <C-j> :bn<CR>
nnoremap <C-k> :bp<CR>

" set 120 character line limit
if exists('+colorcolumn')
  set colorcolumn=121
endif

" turn on rainbow parentheses
let g:lisp_rainbow=1

" don't use syntax for lines longer than 200 characters
set synmaxcol=200

" setup mapping to copy file name
nnoremap <silent> <Leader>cpa :let @+=expand('%:p')<CR>
nnoremap <silent> <Leader>cpr :let @+=expand('%')<CR>

" open file in same directory as current buffer map ,e :e
map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
map ,t :tabe <C-R>=expand("%:p:h") . "/" <CR>
map ,s :split <C-R>=expand("%:p:h") . "/" <CR>

" ctrlp ignore using gtt ignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
" ctrlp don't cache
let g:ctrlp_use_caching = 0

if has('persistent_undo')      "check if your vim version supports it
  set undofile                 "turn on the feature
  set undodir=$HOME/.vim/undo  "directory where the undo files will be stored
  silent !mkdir -p ~/.vim/undo
endif

set mouse=a

let g:db_ui_env_variable_url = 'DATABASE_URL'
function! Scratch()
  vsplit
  noswapfile hide enew
  setlocal buftype=nofile
  setlocal bufhidden=hide
endfunction

function! ScratchFromClipboard()
  call Scratch()
  normal "+p<cr>
endfunction

nnoremap <leader>s :call Scratch()<cr>
nnoremap <leader>s+ :call ScratchFromClipboard()<cr>set splitbelow

" splits should extend rather than replace current window
set splitbelow
set splitright

function! SqlReadable()
  let l:raw = @+
  let l:formatted = l:raw

  " active record to_sql leads with '=> '
  if (strcharpart(l:formatted, 0, 3) == "=> ")
    let l:formatted = strcharpart(l:formatted, 3, strcharlen(l:formatted) - 3)
  endif

  " strip leading and trailing double quotes
  let l:formatted = substitute(l:formatted, '^"\(.*\)"', '\1', '')
  " unescape escaped double quotes
  let l:formatted = substitute(l:formatted, '\\"', '"','g')

  let l:tempname = tempname() . '.sql'
  call writefile(split(l:formatted, '\n'), tempname)
  execute 'split' l:tempname

  :call CocAction('format')
  write
endfunction

nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

" default to using smartcase
set ignorecase
set smartcase

" re-enable this...ideally move it to plugins.lua
" source ~/.vim/coc.nvim.vimrc
