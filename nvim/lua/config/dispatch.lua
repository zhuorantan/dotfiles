local vim = vim

local config = {}

function config.before()
  vim.g.dispatch_no_maps = 1
  vim.g.dispatch_no_tmux_make = 1
end

return config
