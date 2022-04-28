local vim = vim

local M = {}

function M.before()
  vim.keymap.set('n', '<leader>rr', function() require('sniprun').run() end)
  vim.keymap.set('v', '<leader>rr', function() require('sniprun').run('v') end)
  vim.keymap.set('n', '<leader>rR', function() require('sniprun').run('w') end)
end

function M.after()
  local sniprun = require('sniprun')

  sniprun.setup({
    display = { 'TempFloatingWindow' },
  })
end

return M
