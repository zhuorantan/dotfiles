local config = {}

function config.before()
  local bind = require('utils.bind')
  bind.nmap_cmd('<leader>n', 'NvimTreeToggle')
end

function config.after()
  local nvim_tree = require('nvim-tree')
  nvim_tree.setup({
    auto_close = true,
    update_focused_file = {
      enable = true,
    },
  })
end

return config
