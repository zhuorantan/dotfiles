local vim = vim

local config = {}

function config.after()
  vim.g.blamer_enabled = 1
  vim.g.blamer_delay = 500
  vim.g.blamer_relative_time = 1
end

return config
