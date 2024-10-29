local M = {}

print("Zoom plugin loaded")

-- Store zoom state per tab
M.zoomed = {}
M.winrestcmd = {}

local function zoom_toggle(only_restore)
    local tabpage = vim.api.nvim_get_current_tabpage()
    
    if M.zoomed[tabpage] then
        -- Restore the window
        vim.cmd(M.winrestcmd[tabpage])
        M.winrestcmd[tabpage] = nil
        M.zoomed[tabpage] = false
    elseif not only_restore then
        -- Zoom the window
        M.winrestcmd[tabpage] = vim.fn.winrestcmd()
        vim.cmd('resize')
        vim.cmd('vertical resize')
        M.zoomed[tabpage] = true
    end
end

-- Create commands
vim.api.nvim_create_user_command('ZoomToggle', function()
    zoom_toggle(false)
end, {})

vim.api.nvim_create_user_command('ZoomRestore', function()
    zoom_toggle(true)
end, {})

-- Create mapping
vim.keymap.set('n', '<C-W>z', ':ZoomToggle<CR>', { silent = true })

-- Set up autocommand
local group = vim.api.nvim_create_augroup('ZoomToggle', { clear = true })
vim.api.nvim_create_autocmd('WinEnter', {
    group = group,
    pattern = '*',
    callback = function()
        zoom_toggle(true)
    end,
})
