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

  --------------------------------
  -- visual
  --------------------------------
  vim.o.cursorline = true
  vim.o.ruler = true
  vim.o.laststatus = 2

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
  vim.o.autoindent = true
  vim.o.smarttab = true
  vim.o.expandtab = true
  vim.o.shiftround = true

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
end

apply_settings()
