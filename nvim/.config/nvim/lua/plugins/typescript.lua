return {
  {
    'neovim/nvim-lspconfig',
    ft = {'javascript', 'typescript'},
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      require'lspconfig'.ts_ls.setup{
        filetypes = {
          "javascript",
          "typescript",
        },
      }
    end
  }
}