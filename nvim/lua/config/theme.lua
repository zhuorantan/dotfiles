local vim = vim

local config = {}

function config.after()
  if os.getenv('TMUX') and vim.fn.has('termguicolors') then
    vim.o.termguicolors = true
  end

  vim.cmd('colorscheme onedark')
end

return config
