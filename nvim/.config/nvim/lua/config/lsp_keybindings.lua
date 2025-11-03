-- Function to copy diagnostic message at cursor position
local function copy_diagnostic_message()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
    if #diagnostics == 0 then
        vim.notify("No diagnostic message at cursor position", vim.log.levels.WARN)
        return
    end
    
    -- Collect all diagnostic messages
    local messages = {}
    for _, diagnostic in ipairs(diagnostics) do
        local message = diagnostic.message:gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(messages, message)
    end
    
    -- Join multiple diagnostics with newlines
    local text = table.concat(messages, "\n")
    
    -- Copy to system clipboard
    vim.fn.setreg('+', text)
    vim.notify("Copied diagnostic message to clipboard", vim.log.levels.INFO)
end

-- Set up LSP keybindings globally
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', {silent = true})
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', {silent = true})
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', {silent = true})
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', {silent = true})
vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', {silent = true})
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', {silent = true})
vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', {silent = true})
vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', {silent = true})
vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', {silent = true})
vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', {silent = true})
vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', {silent = true})

-- Copy diagnostic message at cursor position
vim.keymap.set('n', '<leader>dc', copy_diagnostic_message, {silent = true, desc = 'Copy diagnostic message'})
