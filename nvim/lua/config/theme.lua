local vim = vim

local config = {}

function config.after()
  vim.cmd('colorscheme onedark')
end

return config
