vim.g.mapleader = "\\"

require("config.lazy")

-- Load LSP keybindings after lazy setup
require("config.lsp_keybindings")

vim.opt.number = true

-- Set tabstop to 2 spaces
vim.opt.tabstop = 2

-- Set shiftwidth to 2 spaces
vim.opt.shiftwidth = 2

-- Use spaces instead of tabs
vim.opt.expandtab = true

vim.opt.wrap = false


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

vim.diagnostic.config({
    virtual_text = false, 
    signs = false,         
    underline = true,     
    update_in_insert = false, 
})

local function show_diagnostics_on_hover()
    local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor",
    }
    vim.diagnostic.open_float(nil, opts)
end

vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = show_diagnostics_on_hover,
})

vim.o.updatetime = 300

-- Auto-format TypeScript files on save using ESLint LSP
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*.ts', '*.tsx', '*.js', '*.jsx'},
  callback = function()
    -- Check if ESLint LSP is attached
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    local eslint_client = nil
    for _, client in ipairs(clients) do
      if client.name == 'eslint' then
        eslint_client = client
        break
      end
    end

    if eslint_client then
      vim.lsp.buf.format({
        async = false,
        filter = function(client)
          return client.name == 'eslint'
        end,
      })
    end
  end,
})

-- load custom plugins
local custom_plugins_dir = vim.fn.stdpath('config') .. '/lua/custom_plugins/'
local custom_plugins = vim.fn.globpath(custom_plugins_dir, '*.lua', false, true)

for _, plugin_path in ipairs(custom_plugins) do
    local plugin_name = plugin_path:match("([^/]+)%.lua$")
    if plugin_name then
      require('custom_plugins.' .. plugin_name)
    end
end

--[[ 
NOTES:
* I didn't autoinstall treesitter stuff
TODO:

* vim projectionist
* my custom plugins
* render-markdown.nvim
* telescope instead of ctrlp?
* switch to comment.nvim and nvim-ts-commentstring instead of vim-commentary?
* luarocks
* replace vim sideways with sibling-swap.nvim?
* replace abolish with textcase?
* review plugins used by https://github.com/josean-dev/dev-environment-files
--]]
