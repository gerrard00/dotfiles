vim.g.mapleader = "\\"

require("config.lazy")

vim.opt.number = true

-- Set tabstop to 2 spaces
vim.opt.tabstop = 2

-- Set shiftwidth to 2 spaces
vim.opt.shiftwidth = 2

-- Use spaces instead of tabs
vim.opt.expandtab = true


vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Open a file in the same directory as the current buffer
vim.api.nvim_set_keymap('n', ',e', ':e <C-R>=fnamemodify(expand("%:h:p"), ":~:.") . "/" <CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ',s', ':split <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ',t', ':tabe <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ',v', ':vsplit <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })

-- Set up shortcuts for moving through buffers
vim.api.nvim_set_keymap('n', '<C-j>', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':bp<CR>', { noremap = true, silent = true })

-- Enable persistent undo
vim.opt.undofile = true

-- Enable ignorecase and smartcase for searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set splits to open below and to the right of the current window
vim.opt.splitbelow = true
vim.opt.splitright = true

--[[ 
TODO:
* Ctrl-P copy logic ot use ag instead of git hs-files
* luarocks
* replace vim sideways with sibling-swap.nvim?
* replace abolish with textcase?
* review plugins used by https://github.com/josean-dev/dev-environment-files
--]]
