local vim = vim

local M = {}

function M.after()
  local bufferline = require('bufferline')

  bufferline.setup({
    options = {
      numbers = 'ordinal',
      always_show_bufferline = false,
      show_close_icon = false,
    },
  })

  for i = 1, 9 do
    vim.keymap.set('n', string.format('<leader>%d', i), string.format('<cmd>BufferLineGoToBuffer %d<cr>', i))
  end
end

return M
