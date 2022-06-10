" load vim defaults
if filereadable($VIMRUNTIME . "/defaults.vim")
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
endif

" auto-install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" configure plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'pangloss/vim-javascript'
Plug 'chriskempson/base16-vim'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'xolox/vim-misc'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-commentary'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-surround'
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
Plug 'kshenoy/vim-signature'
" show indent lines
Plug 'Yggdroot/indentLine'
" needed for a few tim pope plugins
Plug 'tpope/vim-dispatch'
" golang
Plug 'fatih/vim-go', { 'for': ['go']  }
let g:go_fmt_command = "goimports"
" Docker
Plug 'tianon/vim-docker'
" my mocha plugin
Plug 'gerrard00/vim-mocha-only', { 'for': ['javascript'] }
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

Plug 'gerrard00/vim-js-dump', { 'for': ['javascript'] }

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-bundler'

" ruby motions and text objects
Plug 'vim-ruby/vim-ruby'

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

set number

" airline config
" for some reason, auto detect of theme isn't working
" after switching to vim-plug
let g:airline_theme = "base16"
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
let base16colorspace=256  " Access colors present in 256 colorspace
set background=dark
colorscheme base16-twilight

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

" gundo mapping
nnoremap <silent> <F7> :GundoToggle<CR>

" tweak indent line color, got color from colortest script
let g:indentLine_color_term = 18
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
nnoremap <silent> <Leader>cp :let @+=expand('%:p')<CR>

" open file in same directory as current buffer map ,e :e
map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
map ,t :tabe <C-R>=expand("%:p:h") . "/" <CR>
map ,s :split <C-R>=expand("%:p:h") . "/" <CR>

" ctrlp ignore using gtt ignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

source ~/.vim/coc.nvim.vimrc
