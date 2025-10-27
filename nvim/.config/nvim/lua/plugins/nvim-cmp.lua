return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local cmp = require('cmp')

      -- CheckBackspace function for completion (from coc.nvim)
      local function check_backspace()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
      end

      cmp.setup({
        sources = {
          {name = 'nvim_lsp'},
          {name = 'buffer'},
          {name = 'path'},
        },
        mapping = cmp.mapping.preset.insert({
          -- Tab completion like coc.nvim
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn.pumvisible() == 1 then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
            elseif vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            elseif vim.fn['coc#pum#visible']() == 1 then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
            elseif check_backspace() then
              fallback()
            else
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
            end
          end, { 'i', 's' }),
          
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn.pumvisible() == 1 then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
            elseif vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          
          -- Enter to confirm completion
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                -- If completion is visible but no entry is selected, select the first one
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              end
            else
              fallback()
            end
          end, { 'i', 's' }),
          
          -- Ctrl+Space to trigger completion
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
        }),
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        completion = {
          autocomplete = {
            cmp.TriggerEvent.TextChanged,
            cmp.TriggerEvent.InsertEnter,
          },
          keyword_length = 0,
        },
        experimental = {
          ghost_text = true,
        },
      })
    end
  }
}
