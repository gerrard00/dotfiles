set nocompatible              " be iMproved, required
filetype off                  " required

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
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/syntastic'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Valloric/YouCompleteMe', { 'for': ['c', 'cpp', 'javascript'], 'do': 'python3 ./install.py --clang-completer --tern-completer --system-libclang' }
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'xolox/vim-easytags'
Plug 'xolox/vim-misc'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-commentary'
Plug 'ntpeters/vim-better-whitespace'
" http://www.adamwadeharris.com/how-to-switch-from-vundle-to-vim-plug/
function! BuildTern(info)
  if a:info.status == 'installed' || a:info.force
    !npm install
  endif
endfunction
Plug 'ternjs/tern_for_vim', { 'do': function('BuildTern') }
Plug 'tpope/vim-surround'
Plug 'moll/vim-node'
" Only need to enable this plugin temporarily, then run
" TmuxlineSnapshot to create a new file that can be sourced
" from .tmux.conf
" Plug 'edkolev/tmuxline.vim'
" All of your Plugs must be added before the following line
Plug 'rking/ag.vim'
" tmux syntax
Plug 'tmux-plugins/vim-tmux'
" json formatting
Plug 'tpope/vim-jdaddy'
" Add plugins to &runtimepath
call plug#end()

filetype plugin indent on    " required

filetype on

syntax enable

set tabstop=2 shiftwidth=2 expandtab

"this is to  set up simple save with \s
noremap <silent><Leader>s :update<CR>

"syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
"don't auto show location for errors
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_javascript_checkers = ['eslint']

"turn off word wrap
set nowrap

"turn on line numbers...I don't like them, but need a margin
set number

"default ycm conf for c files.
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
" if installed via the default install py script the ycm server 
" crashes if this isn't set. ycm docs suggest it's a mismatch
" between python2 and python3 during install vs usage. 
" let g:ycm_path_to_python_interpreter = "/usr/bin/python"

"tagbar config
nmap <silent> <F8> :TagbarToggle<CR>

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

function! AirlineInit()
  let g:airline_section_x = airline#section#create_right(['tagbar'])
  let g:airline_section_y = ''
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" toggle paste mode
set pastetoggle=<F2>

"get rid of scrollbars
set guioptions-=r
set guioptions-=L

" setup colors
let base16colorspace=256  " Access colors present in 256 colorspace
set background=dark
colorscheme base16-monokai

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

"Ctrlp.vim should ignore stuff in .gitignore
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

"I just want vim-better-whitespace to work on demand
let g:better_whitespace_enabled = 0

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

" setup ternjs key mappings
let g:tern_map_keys=1
let g:tern_show_argument_hints='on_hold'

" tell easytags to stop updating status
let g:easytags_suppress_report = 1

" setup easytags to use jsctags for javascript
let g:easytags_languages = {
  \   'javascript': {
  \       'cmd': 'jsctags',
  \       'args': [],
  \       'fileoutput_opt': '-f',
  \       'stdout_opt': '-f-',
  \       'recurse_flag': '-R'
  \   }
\}

" easier way to go to next buffer
nnoremap gb :bn<CR>

" autoformat xml w/ tidy
au FileType xml setlocal equalprg=tidy\ -xml\ -i\ -w\ 0\ -q\ -\ 2>\/dev\/null\ \|\|\ true

" turn on matchit, so we can match markup tags
source $VIMRUNTIME/macros/matchit.vim

" use python to generate uuid/guids, adapted from vim-nuuuid
" TODO: move this into a custom plugin
function! NewUUID()
python << endpython
import vim
import sys,uuid; 

# do important stuff
vim.command("return \"" + str(uuid.uuid4()) + "\"") # return from the Vim function!
endpython
endfunction

" Mappings
nnoremap <Leader>uuid i<C-R>=NewUUID()<CR><Esc>
inoremap <Leader>uuid <C-R>=NewUUID()<CR>
vnoremap <Leader>uuid c<C-R>=NewUUID()<CR><Esc>

