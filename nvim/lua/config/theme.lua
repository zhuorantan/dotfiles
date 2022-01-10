local vim = vim

local config = {}

function config.after()
  if os.getenv('TMUX') and vim.fn.has('termguicolors') then
    vim.o.termguicolors = true

    vim.g.onedark_terminal_italics = 1
  end

  vim.cmd('colorscheme onedark')

  vim.cmd('hi LspReferenceText cterm=underline gui=underline')
  vim.cmd('hi LspReferenceRead cterm=underline gui=underline')
  vim.cmd('hi LspReferenceWrite cterm=underline gui=underline')
end

return config
