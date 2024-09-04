return {
  {
    'AndrewRadev/sideways.vim',
    keys = {
      -- Normal mode mappings
      { '<C-h>', ':SidewaysJumpLeft<CR>', mode = 'n', desc = 'Jump left argument' },
      { '<C-l>', ':SidewaysJumpRight<CR>', mode = 'n', desc = 'Jump right argument' },
      { '<leader><C-h>', ':SidewaysLeft<CR>', mode = 'n', desc = 'Move argument left' },
      { '<leader><C-l>', ':SidewaysRight<CR>', mode = 'n', desc = 'Move argument right' },
      -- Operator-pending and visual mode mappings
      { 'aa', '<Plug>SidewaysArgumentTextobjA', mode = { 'o', 'x' }, desc = 'Argument text object A' },
      { 'ia', '<Plug>SidewaysArgumentTextobjI', mode = { 'o', 'x' }, desc = 'Argument text object I' },
    },
    lazy = true  -- Ensures lazy loading
  }
}
