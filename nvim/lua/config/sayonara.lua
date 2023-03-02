local vim = vim

local M = {}

function M.before()
  vim.keymap.set('n', '<leader>q', '<cmd>Sayonara<cr>')
  vim.keymap.set('n', '<leader>Q', '<cmd>Sayonara!<cr>')

  vim.g.sayonara_confirm_quit = 1
end

return M
