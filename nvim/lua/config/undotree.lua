local vim = vim

local M = {}

function M.before()
  vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<cr>')
end

return M
