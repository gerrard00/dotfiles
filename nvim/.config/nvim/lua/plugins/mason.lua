return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {'ts_ls'},
        handlers = {
          -- this first function is the "default handler"
          -- it applies to every language server without a "custom handler"
          function(server_name)
            -- Use the new vim.lsp.config API instead of lspconfig
            vim.lsp.config(server_name, {})
            vim.lsp.enable(server_name)
          end,
        }
      })
    end
  }
}