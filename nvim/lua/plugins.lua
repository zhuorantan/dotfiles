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
    setup = [[require('config.tree').before()]],
    config = [[require('config.tree').after()]],
    cmd = 'NvimTreeToggle',
  })

  use {
    'akinsho/nvim-bufferline.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = [[require('config.bufferline').after()]],
  }

  use({
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
  })

  --------------------------------
  -- general enhancements
  --------------------------------
  use({
    'mhinz/vim-sayonara',
    cmd = 'Sayonara',
  })

  -- Async building & commands
  use({
    'tpope/vim-dispatch',
    cmd = { 'Dispatch', 'Make', 'Focus', 'Start' },
  })

  --------------------------------
  -- editing enhancements
  --------------------------------
  use('tpope/vim-repeat')
  use('tpope/vim-surround')
  use('tpope/vim-unimpaired')
  use('tpope/vim-commentary')

  --------------------------------
  -- patches
  --------------------------------
  use({
    'thalesmello/tabfold',
    keys = '<tab>',
  })
end

-- put compiled packer in this path to autoload
local compile_path = vim.fn.stdpath('data') .. '/site/pack/loader/start/packer/plugin/packer_compiled.lua'
packer.init({
  disable_commands = true,
  compile_path = compile_path,
})
return packer.startup(define_plugins)
