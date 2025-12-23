local M = {}
M.diagnostics_enabled = true

local original_config = {
  virtual_text = {
    enabled = true,
    severity = { min = vim.diagnostic.severity.WARN },
    source = "always",
    format = function(diagnostic)
      local icons = {
        [vim.diagnostic.severity.ERROR] = "❌",
        [vim.diagnostic.severity.WARN] = "⚠️",
        [vim.diagnostic.severity.INFO] = "ℹ️",
        [vim.diagnostic.severity.HINT] = "💡",
      }
      return icons[diagnostic.severity] .. " " .. diagnostic.message
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
}

local function toggle_diagnostics()
  if M.diagnostics_enabled then
    vim.diagnostic.config({
      virtual_text = { enabled = false },
      signs = false,
      underline = false,
    })
    M.diagnostics_enabled = false
  else
    vim.diagnostic.config(original_config)
    M.diagnostics_enabled = true
  end
end

vim.api.nvim_create_user_command('ToggleDiagnostics', toggle_diagnostics, {})
