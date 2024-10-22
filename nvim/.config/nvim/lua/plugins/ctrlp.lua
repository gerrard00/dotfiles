return {
  'kien/ctrlp.vim',
  -- Lazy-load ctrlp.vim when pressing Ctrl-p
  keys = {
    { "<C-p>", ":CtrlP<CR>", desc = "CtrlP fuzzy finder" }
  },
  config = function()
    vim.g.ctrlp_user_command = 'ag -l -g ""'

    -- Equivalent of: let g:ctrlp_use_caching = 0
    vim.g.ctrlp_use_caching = 0

    vim.g.ctrlp_cmd = 'CtrlPBuffer'
  end
}
