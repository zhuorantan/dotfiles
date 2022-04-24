local vim = vim
local packer = require('packer')

local function define_plugins(use)
  use('wbthomason/packer.nvim')

  --------------------------------
  -- functionalities
  --------------------------------
  use({
    'kyazdani42/nvim-tree.lua',
    after = { 'nvim-web-devicons' },
    setup = [[require('config.tree').before()]],
    config = [[require('config.tree').after()]],
  })

  use {
    'akinsho/bufferline.nvim',
    after = { 'nvim-web-devicons' },
    config = [[require('config.bufferline').after()]],
  }

  use({
    'mbbill/undotree',
    setup = [[require('config.undotree').before()]],
    cmd = 'UndotreeToggle',
  })

  use({
    'rcarriga/nvim-notify',
    config = [[require('config.notify').after()]],
    fn = 'vim.notify',
    module = 'notify',
  })

  use({
    'michaelb/sniprun',
    run = 'bash ./install.sh',
    setup = [[require('config.sniprun').before()]],
    config = [[require('config.sniprun').after()]],
    module = 'sniprun',
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

  use({ 'ojroques/vim-oscyank' })

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
    run = [[cd app && yarn install]],
    config = [[require('config.markdown-preview').after()]],
    ft = { 'markdown' },
  })

  --------------------------------
  -- lsp
  --------------------------------
  use({
    'williamboman/nvim-lsp-installer',
    requires = { 'neovim/nvim-lspconfig', 'ray-x/lsp_signature.nvim' },
    after = { 'cmp-nvim-lsp' },
    config = [[require('config.lsp.installer').after()]],
  })

  use({
    'creativenull/diagnosticls-configs-nvim',
    requires = { 'neovim/nvim-lspconfig' },
    config = [[require('config.lsp.diagnosticls-configs').after()]],
  })

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
      'onsails/lspkind-nvim',
      'rafamadriz/friendly-snippets',
    },
    config = [[require('config.completion.cmp').after()]],
  })

  use({
    'windwp/nvim-autopairs',
    after = { 'nvim-cmp' },
    config = [[require('config.completion.autopairs').after()]],
  })

  use('github/copilot.vim')

  --------------------------------
  -- search
  --------------------------------
  use({
    'ibhagwan/fzf-lua',
    requires = { 'vijaymarupudi/nvim-fzf' },
    after = { 'nvim-web-devicons' },
    setup = [[require('config.fzf').before()]],
    config = [[require('config.fzf').after()]],
    module = 'fzf-lua',
  })

  --------------------------------
  -- git
  --------------------------------
  use({
    'tpope/vim-fugitive',
    requires = { 'cedarbaum/fugitive-azure-devops.vim' },
    setup = [[require('config.git.fugitive').before()]],
    cmd = { 'Git', 'Gdiffsplit', 'GBrowse' },
  })

  use('tpope/vim-rhubarb')

  use({
    'junegunn/gv.vim',
    wants = 'vim-fugitive',
    setup = [[require('config.git.gv').before()]],
    cmd = 'GV',
  })

  use({
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = [[require('config.git.gitsigns').after()]],
  })

  use({
    'APZelos/blamer.nvim',
    config = [[require('config.git.blamer').after()]],
  })

  --------------------------------
  -- syntax highlighting
  --------------------------------
  use({
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-tree-docs',
    },
    config = [[require('config.treesitter').after()]],
    run = ':TSUpdate',
  })

  --------------------------------
  -- interface
  --------------------------------
  use({
    'kyazdani42/nvim-web-devicons',
    config = [[require('config.web-devicons').after()]],
  })

  use({
    'hoob3rt/lualine.nvim',
    after = { 'nvim-web-devicons' },
    config = [[require('config.lualine').after()]],
  })

  use({
    'navarasu/onedark.nvim',
    config = [[require('config.theme').after()]],
  })

  --------------------------------
  -- org mode
  --------------------------------
  use({
    'nvim-orgmode/orgmode',
    after = { 'nvim-treesitter' },
    config = [[require('config.orgmode').after()]],
  })
end

-- put compiled packer in this path to autoload
local compile_path = vim.fn.stdpath('data') .. '/site/pack/loader/start/packer/plugin/packer_compiled.lua'
packer.init({
  disable_commands = true,
  compile_path = compile_path,
  autoremove = true,
})
return packer.startup(define_plugins)
