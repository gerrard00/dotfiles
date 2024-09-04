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
-- Open a horizontal split in the same directory as the current buffer
vim.api.nvim_set_keymap('n', ',s', ':split <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })
-- Open a new tab in the same directory as the current buffer
vim.api.nvim_set_keymap('n', ',t', ':tabe <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })
-- Open a vertical split in the same directory as the current buffer
vim.api.nvim_set_keymap('n', ',v', ':vsplit <C-R>=fnamemodify(expand("%:p:h"), ":~:.") . "/" <CR>', { noremap = true, silent = false })

--[[ 
TODO:

* luarocks
* replace vim sideways with sibling-swap.nvim?
* replace abolish with textcase?
--]]
