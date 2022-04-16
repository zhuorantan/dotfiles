local vim = vim

local M = {}

function M.before()
  vim.keymap.set('n', '<leader>gv', '<cmd>GV --all<cr>')
  vim.keymap.set('n', '<leader>gV', '<cmd>GV<cr>')
end

return M
