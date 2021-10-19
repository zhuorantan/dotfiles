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

packer.init({ disable_commands = true })
return packer.startup(define_plugins)
