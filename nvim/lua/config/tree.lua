local vim = vim

local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>n', 'NvimTreeFindFileToggle')

  vim.g.nvim_tree_ignore = { '.git' }
  vim.g.nvim_tree_quit_on_open = 1
  vim.g.nvim_tree_indent_markers = 1
end

function config.after()
  local nvim_tree = require('nvim-tree')
  nvim_tree.setup({
    auto_close = true,
    update_focused_file = {
      enable = true,
    },
    diagnostics = {
      enable = true,
    },
  })
end

return config
