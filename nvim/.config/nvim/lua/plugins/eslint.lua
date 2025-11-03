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

      -- Configure ESLint LSP
      require('lspconfig').eslint.setup({
        capabilities = capabilities,
        filetypes = {
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
        },
        root_dir = function()
          return vim.fs.dirname(vim.fs.find({
            'package.json',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.json',
            '.eslintrc.yaml',
            '.eslintrc.yml',
            '.git'
          }, {path = vim.fn.getcwd(), upward = true})[1] or vim.fn.getcwd())
        end,
        settings = {
          eslint = {
            validate = 'on',
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = 'separateLine',
              },
              showDocumentation = {
                enable = true,
              },
            },
          },
        },
      })
    end
  }
}
