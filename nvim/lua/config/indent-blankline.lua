local M = {}

function M.after()
  local indent_blankline = require('indent_blankline')

  indent_blankline.setup({
    buftype_exclude = { 'terminal', 'help', 'nofile' },
  })
end

return M
