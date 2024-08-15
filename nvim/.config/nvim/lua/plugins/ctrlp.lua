return {
  'kien/ctrlp.vim',
  -- Lazy-load ctrlp.vim when pressing Ctrl-p
  keys = {
    { "<C-p>", ":CtrlP<CR>", desc = "CtrlP fuzzy finder" }
  },
  config = function()
    -- Equivalent of: let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
    vim.g.ctrlp_user_command = { '.git', 'cd %s && git ls-files -co --exclude-standard' }

    -- Equivalent of: let g:ctrlp_use_caching = 0
    vim.g.ctrlp_use_caching = 0
  end
}
