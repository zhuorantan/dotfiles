local vim = vim

local M = {}

function M.before()
  vim.keymap.set('n', '<leader>n', '<cmd>NvimTreeFindFileToggle<cr>')
end

function M.after()
  local nvim_tree = require('nvim-tree')
  nvim_tree.setup({
    renderer = {
      indent_markers = {
        enable = true,
      },
    },
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

return M
