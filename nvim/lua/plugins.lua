local vim = vim
local packer = require('packer')

local function define_plugins(use)
  use('wbthomason/packer.nvim')

  --------------------------------
  -- vim enhancements
  --------------------------------
  use({ 'mbbill/undotree', cmd = 'UndotreeToggle' })
  use({ 'mhinz/vim-sayonara', cmd = 'Sayonara' })

  -- Async building & commands
  use({ 'tpope/vim-dispatch', cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } })
end

local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
packer.init({
  disable_commands = true,
  compile_path = vim.fn.stdpath('data') .. '/site/packer_compiled.vim'
})
return packer.startup(define_plugins)
