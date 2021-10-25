local vim = vim

local function ensure_packer_installed()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  end
end

local function packer_sync()
  ensure_packer_installed()
  vim.cmd('packadd packer.nvim')

  package.loaded['plugins'] = nil
  local plugins = require('plugins')
  plugins.sync()
end

return packer_sync
