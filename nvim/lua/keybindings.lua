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

  bind.vmap('<leader>d', '"+d')
  bind.nmap('<leader>d', '"+d')
  bind.nmap('<leader>D', '"+D')
  bind.nmap('<leader>dd', '"+dd')

  bind.nmap('<leader>p', '"+p')
  bind.nmap('<leader>P', '"+P')
  bind.vmap('<leader>p', '"+p')
  bind.vmap('<leader>P', '"+P')

  bind.nmap_cmd('<leader>s', 'let @+=@"') -- sync to system clipboard

  --------------------------------
  -- window
  --------------------------------
  bind.nmap_cmd('<C-w>z', [[lua require('utils.zoom').toggle()]])

  --------------------------------
  -- terminal
  --------------------------------
  bind.nmap_cmd('<leader>t', 'terminal')
  bind.nmap_cmd('<C-w>t', '16split | terminal')
  bind.nmap_cmd('<C-w>T', 'vsplit | terminal')

  --------------------------------
  -- editing
  --------------------------------
  -- Press * to search for the term under the cursor or a visual selection and
  -- then press a key below to replace all instances of it in the current file.
  bind.nmap('<leader>R', ':%s///g<left><left>')
  bind.xmap('<leader>R', ':%s///g<left><left>')
end

map_leader()
apply_key_bindings()
