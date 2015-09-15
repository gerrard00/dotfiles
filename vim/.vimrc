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
Plugin 'othree/javascript-libraries-syntax.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

filetype on

syntax enable
" setup colors 
set background=dark
let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-monokai

"transparent background
hi Normal ctermbg=none
 
:set tabstop=4 shiftwidth=2 expandtab
"this is to  set up simple save with \s
noremap <Leader>s :update

"syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 1 
let g:syntastic_check_on_open = 0 
let g:syntastic_check_on_wq = 1

"turn off word wrap
:set nowrap

"setup javascript-libraries-syntax
let g:used_javascript_libs = 'jquery,underscore,angularjs,angularui,angularuirouter'

"turn on line numbers...I don't like them, but need a margin
:set number

