local vim = vim

local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>n', 'NvimTreeFindFileToggle')

  vim.g.nvim_tree_indent_markers = 1
end

function config.after()
  local nvim_tree = require('nvim-tree')
  nvim_tree.setup({
    update_focused_file = {
      enable = true,
    },
    diagnostics = {
      enable = true,
    },
    filters = {
      custom = { '.git' },
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  })
end

return config
