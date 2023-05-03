local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tpope/vim-sensible",
  "pangloss/vim-javascript",
  "PotatoesMaster/i3-vim-syntax",
  "scrooloose/nerdtree",
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "xolox/vim-misc",
  "ctrlpvim/ctrlp.vim",
  "tpope/vim-commentary",
  "ntpeters/vim-better-whitespace",
  "tpope/vim-surround",
  { "moll/vim-node", ft ="javascript" },
  -- new search hotness
  "mhinz/vim-grepper",
  -- tmux syntax
  "tmux-plugins/vim-tmux",
  -- json formatting
  "tpope/vim-jdaddy",
  -- docker syntax
  "tianon/vim-docker",
  -- signature for mark magic
  "kshenoy/vim-signature",
  -- show indent lines
  "Yggdroot/indentLine",
  -- needed for a few tim pope plugins
  "tpope/vim-dispatch",
  -- golang
  { "fatih/vim-go", ft= "go" },
  -- Docker
  "tianon/vim-docker",
  -- my mocha plugin
  { "gerrard00/vim-mocha-only", ft = "javascript" },
  { "kovisoft/slimv", ft="scheme" },
  -- my single buffer diff plugin
  "gerrard00/vim-diffbuff",
  -- pgsql syntax
  "lifepillar/pgsql.vim",
  -- better jsx highlighting for react
  "mxw/vim-jsx",
  "easymotion/vim-easymotion",
  { "gerrard00/vim-js-dump", ft="javascript" },
  { "neoclide/coc.nvim", branch = "release"},
  "tpope/vim-rails",
  "tpope/vim-rake",
  "tpope/vim-bundler",
  "tpope/vim-endwise",
  -- ruby syntax
  "vim-ruby/vim-ruby",

  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-ui",

  "tpope/vim-obsession",

  -- nord all the things?
  "arcticicestudio/nord-vim",

  -- sick of moving arguments
  "AndrewRadev/sideways.vim",

  -- mainly for HTML and URL encoding/decoding
  "tpope/vim-unimpaired",

 { "iamcco/markdown-preview.nvim", build= "cd app && npm install" },

  "keith/swift.vim"
})

--[[
nnoremap <leader>g :Grepper -tool ag<cr>
nnoremap <leader>G :Grepper -tool ag -cword -noprompt<cr>
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

-- required for vim-jsx to work on .js files
let g:jsx_ext_required = 0
let g:go_fmt_command = "goimports",
--]]
