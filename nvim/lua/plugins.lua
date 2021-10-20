local vim = vim
local packer = require('packer')

local function define_plugins(use)
  use('wbthomason/packer.nvim')

  --------------------------------
  -- functionalities
  --------------------------------
  use({
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    setup = [[require('config.nvim_tree').before()]],
    config = [[require('config.nvim_tree').after()]],
    cmd = 'NvimTreeToggle',
  })

  use({ 'mbbill/undotree', cmd = 'UndotreeToggle' })

  --------------------------------
  -- general enhancements
  --------------------------------
  use({ 'mhinz/vim-sayonara', cmd = 'Sayonara' })

  -- Async building & commands
  use({ 'tpope/vim-dispatch', cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } })

  --------------------------------
  -- patches
  --------------------------------
  use({ 'thalesmello/tabfold', keys = '<tab>' })
end

-- put compiled packer in this path to autoload
local compile_path = vim.fn.stdpath('data') .. '/site/pack/loader/start/packer/plugin/packer_compiled.lua'
packer.init({
  disable_commands = true,
  compile_path = compile_path,
})
return packer.startup(define_plugins)
