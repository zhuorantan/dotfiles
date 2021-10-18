local vim = vim

local global = require('core.global')

local function apply_settings()
  --------------------
  -- general
  --------------------
  vim.o.undofile = true
  vim.o.hidden = true

  vim.o.inccommand = 'nosplit'

  --------------------
  -- display
  --------------------
  vim.o.cursorline = true

  --------------------
  -- navigation
  --------------------
  vim.o.scrolloff = 1
  vim.o.sidescrolloff = 5

  --------------------
  -- gui
  --------------------
  vim.o.mouse = 'nvi'
end

apply_settings()
