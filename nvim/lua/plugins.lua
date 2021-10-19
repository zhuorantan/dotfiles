local vim = vim
local packer = require('packer')

local function define_plugins(use)
  use('wbthomason/packer.nvim')

  --------------------------------
  -- buffer management
  --------------------------------
  use({ 'mhinz/vim-sayonara', opt = true, cmd = 'Sayonara' })
end

packer.init({ disable_commands = true })
return packer.startup(define_plugins)
