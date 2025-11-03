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
        ensure_installed = {'ts_ls', 'eslint'},
        handlers = {
          -- this first function is the "default handler"
          -- it applies to every language server without a "custom handler"
          function(server_name)
            -- Only set up servers that aren't already configured
            if server_name ~= 'ts_ls' and server_name ~= 'eslint' then
              local capabilities = vim.tbl_deep_extend(
                'force',
                vim.lsp.protocol.make_client_capabilities(),
                require('cmp_nvim_lsp').default_capabilities()
              )
              vim.lsp.config(server_name, {
                capabilities = capabilities,
              })
              vim.lsp.enable(server_name)
            end
          end,
        }
      })
    end
  }
}