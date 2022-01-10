local vim = vim

local config = {}

function config.after()
  local onedark = require('onedark')

  if os.getenv('TMUX') and vim.fn.has('termguicolors') then
    vim.o.termguicolors = true
  end

  onedark.setup({
    toggle_style_key = '<leader>on',
  })
  onedark.load()
end

return config
