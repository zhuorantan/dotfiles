local vim = vim
local config = {}

local lsp_status = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
}

function config.after()
  local lualine = require('lualine')

  vim.o.showmode = false
  lualine.setup({
    options = {
      theme = 'onedark',
    },
    sections = {
      lualine_b = { 'branch', 'b:gitsigns_status' },
      lualine_c = { lsp_status, 'filename' }
    },
    extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
  })
end

return config
