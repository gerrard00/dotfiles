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
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
filetype on

syntax enable
colorscheme base16-monokai
:set tabstop=2 shiftwidth=2 expandtab
"this is to  set up simple save with \s
noremap <Leader>s :update

