-- LSP keybindings configuration
return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    init = function()
      vim.opt.signcolumn = 'yes'
    end,
  }
}
