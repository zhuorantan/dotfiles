local vim = vim
local bind = require('utils.bind')

local function map_leader()
  vim.g.mapleader = ' '
  bind.nmap(' ', '')
  bind.xmap(' ', '')
end

local function apply_key_bindings()
  --------------------------------
  -- navigation
  --------------------------------
  -- center
  bind.nmap('n', 'nzzzv')
  bind.nmap('N', 'Nzzzv')
  bind.nmap('*', '*zzzv')
  bind.nmap('#', '#zzzv')
  bind.nmap('<leader> ', 'zz:nohlsearch<CR>', { silent = true })

  -- buffer
  bind.nmap_cmd('<leader><C-h>', 'bprevious')
  bind.nmap_cmd('<leader><C-l>', 'bnext')
  bind.nmap('<leader><tab>', '<C-^>')

  --------------------------------
  -- buffer management
  --------------------------------
  bind.nmap_cmd('<leader>N', 'enew')
  bind.nmap_cmd('<leader>w', 'w')
  bind.cmap('w!!', 'w !sudo tee > /dev/null %') -- allow saving of files as sudo

  --------------------------------
  -- clipboard
  --------------------------------
  bind.nmap('Y', 'y$') -- fix

  bind.vmap('<leader>y', '"+y')
  bind.nmap('<leader>y', '"+y')
  bind.nmap('<leader>Y', '"+y$')
  bind.nmap('<leader>yy', '"+yy')

  bind.nmap('<leader>p', '"+p')
  bind.nmap('<leader>P', '"+P')
  bind.vmap('<leader>p', '"+p')
  bind.vmap('<leader>P', '"+P')
end

map_leader()
apply_key_bindings()
