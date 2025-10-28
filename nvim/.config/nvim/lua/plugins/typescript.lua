return {
  {
    'neovim/nvim-lspconfig',
    ft = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact'},
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Get capabilities from cmp_nvim_lsp
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
      )
      
      -- Enhanced ts_ls configuration using modern API
      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        filetypes = {
          "javascript",
          "typescript",
          "javascriptreact", 
          "typescriptreact",
        },
        root_dir = vim.fs.dirname(vim.fs.find({'package.json', 'tsconfig.json', 'jsconfig.json', '.git'}, {path = vim.fn.getcwd(), upward = true})[1] or vim.fn.getcwd()),
        settings = {
          typescript = {
            inlayHints = {
              enabled = true,
            },
            preferences = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              completeFunctionCalls = true,
            },
          },
          javascript = {
            inlayHints = {
              enabled = true,
            },
            preferences = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              completeFunctionCalls = true,
            },
          },
        },
      })
      
      -- Enable the ts_ls config
      vim.lsp.enable('ts_ls')
    end
  }
}