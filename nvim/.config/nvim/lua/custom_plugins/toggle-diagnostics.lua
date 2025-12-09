local M = {}
M.diagnostics_enabled = true

local function toggle_diagnostics()
  if M.diagnostics_enabled then
    vim.diagnostic.hide()
    M.diagnostics_enabled = false
  else
    vim.diagnostic.show()
    M.diagnostics_enabled = true
  end
end

vim.api.nvim_create_user_command('ToggleDiagnostics', toggle_diagnostics, {})
