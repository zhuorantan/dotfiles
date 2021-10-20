local vim = vim
local config = {}

local function lsp_status()
  if vim.lsp.buf_get_clients() == 0 then
    return
  end

  local lsp_status = require('lsp-status')
  return lsp_status.status()
end

function config.after()
  local lualine = require('lualine')

  vim.o.showmode = false
  lualine.setup({
    sections = {
      lualine_b = { 'branch', lsp_status },
    },
    extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
  })
end

return config
