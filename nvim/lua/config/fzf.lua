local vim = vim

local M = {}

function M.before()
  local fzf = require('fzf-lua')

  vim.keymap.set('n', '<C-p>', fzf.files)
  vim.keymap.set('n', '<leader><C-p>', function () fzf.files({ fd_opts = '--color never --type f --hidden --follow --no-ignore' }) end)
  vim.keymap.set('n', '<leader>/', fzf.live_grep)
  vim.keymap.set('x', '<leader>/', fzf.grep_visual)
  vim.keymap.set('n', '<leader>?', fzf.live_grep_resume)
  vim.keymap.set('n', '<leader>fw', fzf.grep_cword)
  vim.keymap.set('n', '<leader>fb', fzf.buffers)
  vim.keymap.set('n', '<leader>fc', fzf.commands)
  vim.keymap.set('n', '<leader>fq', fzf.quickfix)
  vim.keymap.set('n', '<leader>ft', fzf.filetypes)
  vim.keymap.set('n', '<leader>fr', fzf.registers)
  vim.keymap.set('n', '<leader>fh', fzf.help_tags)

  vim.keymap.set('n', '<leader>fs', fzf.git_status)
  vim.keymap.set('n', '<leader>fg', fzf.git_branches)

  vim.api.nvim_create_augroup('fzf', {})
  vim.api.nvim_create_autocmd('FileType', {
    group = 'fzf',
    pattern = 'fzf',
    callback = function ()
      vim.keymap.del('t', '<esc>', { buffer = true })
    end
  })
end

function M.after()
  local fzf = require('fzf-lua')

  fzf.setup({})
end

return M
