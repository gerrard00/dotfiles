require("config.lazy")


vim.opt.number = true

-- Set tabstop to 2 spaces
vim.opt.tabstop = 2

-- Set shiftwidth to 2 spaces
vim.opt.shiftwidth = 2

-- Use spaces instead of tabs
vim.opt.expandtab = true

vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

--[[ 
TODO:

* luarocks

--]]
