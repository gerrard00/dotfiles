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
"hi Normal ctermbg=none
hi LineNr ctermbg=none
 
:set tabstop=2 shiftwidth=2 expandtab

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

"turn on line numbers...I don't like them, but need a margin
":set number

"default ycm conf for c files.
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

"tagbar config
nmap <silent> <F8> :TagbarToggle<CR>

" airline config
"let g:airline_powerline_fonts = 0

"powerline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
"let g:airline_right_alt_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''


function! AirlineInit()
  let g:airline_section_x = airline#section#create_right(['tagbar'])
  let g:airline_section_y = '' 
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" toggle paste mode
set pastetoggle=<F2>
