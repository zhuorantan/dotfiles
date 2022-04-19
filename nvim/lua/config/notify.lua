local vim = vim

local M = {}

function M.after()
  vim.notify = require('notify')
end

return M
