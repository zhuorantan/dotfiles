local vim = vim

local function apply_settings()
  --------------------------------
  -- general
  --------------------------------
  vim.o.undofile = true
  vim.o.hidden = true
  vim.o.secure = true
  vim.o.inccommand = 'nosplit'
  vim.o.updatetime = 100
  vim.o.foldmethod = 'indent'
  vim.o.foldlevelstart = 99 -- start file with all folds opened
  vim.o.autowrite = true

  --------------------------------
  -- visual
  --------------------------------
  vim.o.cursorline = true
  vim.o.ruler = true
  vim.o.laststatus = 2

  vim.cmd([[sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=]])
  vim.cmd([[sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=]])
  vim.cmd([[sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=]])
  vim.cmd([[sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=]])
  --------------------------------
  -- navigation
  --------------------------------
  vim.o.scrolloff = 1
  vim.o.sidescrolloff = 5
  vim.o.splitright = true
  vim.o.splitbelow = true

  --------------------------------
  -- indentation
  --------------------------------
  vim.o.smartindent = true
  vim.o.expandtab = true
  vim.o.shiftround = true
  vim.o.shiftwidth = 2
  vim.o.smarttab = true
  vim.o.softtabstop = 2

  --------------------------------
  -- search
  --------------------------------
  vim.o.incsearch = true
  vim.o.hlsearch = true
  vim.o.ignorecase = true
  vim.o.smartcase = true

  --------------------------------
  -- gui
  --------------------------------
  vim.o.mouse = 'nvi'

  --------------------------------
  -- filetype
  --------------------------------
  vim.g.do_filetype_lua = 1
  vim.g.did_load_filetypes = 0
end

apply_settings()
