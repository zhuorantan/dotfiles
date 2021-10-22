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
    setup = [[require('config.undotree').before()]],
    cmd = 'UndotreeToggle',
  })

  --------------------------------
  -- general enhancements
  --------------------------------
  use({
    'mhinz/vim-sayonara',
    setup = [[require('config.sayonara').before()]],
    cmd = 'Sayonara',
  })

  -- Async building & commands
  use({
    'tpope/vim-dispatch',
    config = [[require('config.dispatch').before()]],
    cmd = { 'Dispatch', 'Make', 'Focus', 'Start' },
  })

  --------------------------------
  -- editing enhancements
  --------------------------------
  use('tpope/vim-repeat')
  use('tpope/vim-surround')
  use('tpope/vim-unimpaired')
  use('tpope/vim-commentary')
  use('tpope/vim-sleuth')

  use({
    'iamcco/markdown-preview.nvim',
    run = [[require('config.markdown_preview').run()]],
    config = [[require('config.markdown_preview').after()]],
    ft = { 'markdown' },
  })

  --------------------------------
  -- lsp
  --------------------------------
  use({
    'neovim/nvim-lspconfig',
    after = { 'nvim-cmp', 'lsp-status.nvim' },
  })

  use({
    'williamboman/nvim-lsp-installer',
    after = { 'nvim-lspconfig' },
    config = [[require('config.lsp.installer').after()]],
  })

  use('nvim-lua/lsp-status.nvim')

  --------------------------------
  -- completion
  --------------------------------
  use({
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-nvim-lua',
      'ray-x/cmp-treesitter',
    },
    config = [[require('config.cmp').after()]],
  })

  use({
    'windwp/nvim-autopairs',
    config = [[require('config.autopairs').after()]],
  })

  --------------------------------
  -- search
  --------------------------------
  use({
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      { 'nvim-telescope/telescope-frecency.nvim', requires = 'tami5/sql.nvim' },
    },
    setup = [[require('config.telescope').before()]],
    config = [[require('config.telescope').after()]],
    cmd = 'Telescope',
  })

  use({
    "AckslD/nvim-neoclip.lua",
    config = [[require('config.neoclip').after()]],
    event = { 'TextYankPost' },
  })

  --------------------------------
  -- git
  --------------------------------
  use({
    'tpope/vim-fugitive',
    setup = [[require('config.fugitive').before()]],
    cmd = { 'Git', 'Gdiffsplit' },
  })

  use('tpope/vim-rhubarb')

  use({
    'junegunn/gv.vim',
    wants = 'vim-fugitive',
    setup = [[require('config.gv').before()]],
    cmd = 'GV',
  })

  use({
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = [[require('config.gitsigns').after()]],
  })

  --------------------------------
  -- syntax highlighting
  --------------------------------
  use({
    'nvim-treesitter/nvim-treesitter',
    requires = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = [[require('config.treesitter').after()]],
    run = ':TSUpdate',
  })

  --------------------------------
  -- interface
  --------------------------------
  use({
    'hoob3rt/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', 'nvim-lua/lsp-status.nvim' },
    config = [[require('config.lualine').after()]],
  })

  use({
    'joshdick/onedark.vim',
    config = [[require('config.theme').after()]],
  })

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
