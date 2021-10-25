local vim = vim

local config = {}

function config.after()
  if os.getenv('TMUX') and vim.fn.has('termguicolors') then
    vim.o.termguicolors = true

    vim.g.onedark_terminal_italics = 1
  end

  vim.cmd('colorscheme onedark')
end

return config
