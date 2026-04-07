local function copy_path(expand_str, label)
  local path = vim.fn.expand(expand_str)
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. label .. ": " .. path, vim.log.levels.INFO)
end

vim.keymap.set("n", "<Leader>cpa", function()
  copy_path("%:p", "absolute path")
end, { silent = true, desc = "Copy absolute path" })

vim.keymap.set("n", "<Leader>cpr", function()
  copy_path("%", "relative path")
end, { silent = true, desc = "Copy relative path" })
