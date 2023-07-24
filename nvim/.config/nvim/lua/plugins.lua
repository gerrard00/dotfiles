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

  "keith/swift.vim",
  "simrat39/symbols-outline.nvim"
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

local symbolsOutlineOpts = {
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = 'right',
  relative_width = true,
  width = 25,
  auto_close = false,
  show_numbers = false,
  show_relative_numbers = false,
  show_symbol_details = true,
  preview_bg_highlight = 'Pmenu',
  autofold_depth = nil,
  auto_unfold_hover = true,
  fold_markers = { '', '' },
  wrap = false,
  keymaps = { -- These keymaps can be a string or a table for multiple keys
    close = {"<Esc>", "q"},
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
    fold = "h",
    unfold = "l",
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
  symbols = {
    File = { icon = "", hl = "@text.uri" },
    Module = { icon = "", hl = "@namespace" },
    Namespace = { icon = "", hl = "@namespace" },
    Package = { icon = "", hl = "@namespace" },
    Class = { icon = "𝓒", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "", hl = "@method" },
    Field = { icon = "", hl = "@field" },
    Constructor = { icon = "", hl = "@constructor" },
    Enum = { icon = "ℰ", hl = "@type" },
    Interface = { icon = "ﰮ", hl = "@type" },
    Function = { icon = "", hl = "@function" },
    Variable = { icon = "", hl = "@constant" },
    Constant = { icon = "", hl = "@constant" },
    String = { icon = "𝓐", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "⊨", hl = "@boolean" },
    Array = { icon = "", hl = "@constant" },
    Object = { icon = "⦿", hl = "@type" },
    Key = { icon = "🔐", hl = "@type" },
    Null = { icon = "NULL", hl = "@type" },
    EnumMember = { icon = "", hl = "@field" },
    Struct = { icon = "𝓢", hl = "@type" },
    Event = { icon = "🗲", hl = "@type" },
    Operator = { icon = "+", hl = "@operator" },
    TypeParameter = { icon = "𝙏", hl = "@parameter" },
    Component = { icon = "", hl = "@function" },
    Fragment = { icon = "", hl = "@constant" },
  },
}
require("symbols-outline").setup(symbolsOutlineOpts)
