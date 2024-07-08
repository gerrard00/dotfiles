vim.keymap.set("n", "<c-P>", require('fzf-lua').files, { desc = "Fzf Files" })
vim.keymap.set("n", "<c-B>", require('fzf-lua').buffers, { desc = "Fzf Files" })

return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
  }
}
