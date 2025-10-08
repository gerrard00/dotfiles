return {
  {
    'neovim/nvim-lspconfig',
    ft = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact'},
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      -- Use the new vim.lsp.config API to customize the ts_ls config
      vim.lsp.config('ts_ls', {
        filetypes = {
          "javascript",
          "typescript",
          "javascriptreact", 
          "typescriptreact",
        },
        settings = {
          typescript = {
            inlayHints = {
              enabled = true,
            },
          },
          javascript = {
            inlayHints = {
              enabled = true,
            },
          },
        },
      })
      
      -- Enable the ts_ls config
      vim.lsp.enable('ts_ls')
    end
  }
}