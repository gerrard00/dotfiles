"setup vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-sensible'
Plugin 'pangloss/vim-javascript'
" cool color scheme, but I don't want to use it now Plugin 'goatslacker/mango.vim'
Plugin 'chriskempson/base16-vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/syntastic'
Plugin 'PotatoesMaster/i3-vim-syntax'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'xolox/vim-easytags'
Plugin 'xolox/vim-misc'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-commentary'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

filetype on

syntax enable
 
:set tabstop=2 shiftwidth=2 expandtab

"this is to  set up simple save with \s
noremap <silent><Leader>s :update<CR>

"syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
"don't auto show location for errors
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0 
let g:syntastic_check_on_wq = 1

"turn off word wrap
:set nowrap

"turn on line numbers...I don't like them, but need a margin
:set number

"default ycm conf for c files.
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

"tagbar config
nmap <silent> <F8> :TagbarToggle<CR>

" airline config
let g:airline_powerline_fonts = 1

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

"have <ENTER> add a new line staying in normal mode
nmap <CR> o<Esc>

"Ctrlp.vim should ignore stuff in .gitignore
 let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
