local vim = vim
local config = {}

local function lsp_status()
  if vim.lsp.buf_get_clients() == 0 then
    return
  end

  return require('lsp-status').status()
end

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
