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

-- put compiled packer in this path to autoload
local compile_path = vim.fn.stdpath('data') .. '/site/pack/loader/start/packer/plugin/packer_compiled.lua'
packer.init({
  disable_commands = true,
  compile_path = compile_path,
})
return packer.startup(define_plugins)
