" load vim defaults
if filereadable($VIMRUNTIME . "/defaults.vim")
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
endif

" configure plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'pangloss/vim-javascript'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'xolox/vim-misc'
Plug 'ntpeters/vim-better-whitespace'
Plug 'moll/vim-node', { 'for': 'javascript' }
" Only need to enable this plugin temporarily, then run
" TmuxlineSnapshot to create a new file that can be sourced
" from .tmux.conf
" Plug 'edkolev/tmuxline.vim'


" new search hotness
Plug 'mhinz/vim-grepper'
nnoremap <leader>g :Grepper -tool ag<cr>
nnoremap <leader>G :Grepper -tool ag -cword -noprompt<cr>
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

" tmux syntax
Plug 'tmux-plugins/vim-tmux'
" json formatting
Plug 'tpope/vim-jdaddy'
" docker syntax
Plug 'tianon/vim-docker'
" signature for mark magic
" used marks.nvim instead
" Plug 'kshenoy/vim-signature'

" show indent lines
" used indent-blankline
" Plug 'Yggdroot/indentLine'
" needed for a few tim pope plugins
Plug 'tpope/vim-dispatch'
" golang
Plug 'fatih/vim-go', { 'for': ['go']  }
let g:go_fmt_command = "goimports"
" Docker
Plug 'tianon/vim-docker'
" my mocha plugin
Plug 'gerrard00/vim-mocha-only', { 'for': ['javascript', 'typescript'] }
Plug 'kovisoft/slimv', { 'for': ['scheme'] }
" my single buffer diff plugin
Plug 'gerrard00/vim-diffbuff'
" Plug '~/projects/vimdiffbuff'
" pgsql syntax
Plug 'lifepillar/pgsql.vim'
" better jsx highlighting for react
Plug 'mxw/vim-jsx'
" required for vim-jsx to work on .js files
let g:jsx_ext_required = 0

Plug 'easymotion/vim-easymotion'

Plug 'gerrard00/vim-js-dump', { 'for': ['javascript', 'typescriptreact'] }

Plug 'tpope/vim-endwise'

Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

" mainly for HTML and URL encoding/decoding
Plug 'tpope/vim-unimpaired'

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

" want ir and ar for ruby blocks
Plug 'kana/vim-textobj-user'

" sticking w/ vscode debugger for now
" won't seem to work with the dynamic bindings stuff if this isn't set here
" let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
" Plug 'puremourning/vimspector', { 'for': ['javascript', 'typescriptreact'] }

" mostly for converting case like crs, crm, cr-, cr. etc for changing variable case
Plug 'tpope/vim-abolish'

Plug 'tpope/vim-projectionist'

Plug 'storyn26383/vim-vue'

Plug 'PratikBhusal/vim-grip'

Plug 'liuchengxu/vista.vim'

" Add plugins to &runtimepath
call plug#end()

filetype plugin indent on    " required

filetype on

" https://stackoverflow.com/a/33380495/1011470
if !exists("g:syntax_on")
    syntax enable
endif

set tabstop=2 shiftwidth=2 expandtab

"turn off word wrap
set nowrap

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
set cursorline
set cursorlineopt=number
highlight Visual cterm=bold gui=bold

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

" make mouse work w/ vim in tmux
set ttymouse=xterm2
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

" default to using smartcase
set ignorecase
set smartcase

source ~/.vim/vimspector.vimrc
