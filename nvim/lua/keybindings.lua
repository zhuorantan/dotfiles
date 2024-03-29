local vim = vim

local function map_leader()
  vim.g.mapleader = ' '
  vim.keymap.set({ 'n', 'x' }, ' ', '')
end

local function apply_key_bindings()
  --------------------------------
  -- navigation
  --------------------------------
  -- center
  vim.keymap.set('n', 'n', 'nzzzv')
  vim.keymap.set('n', 'N', 'Nzzzv')
  vim.keymap.set('n', '*', '*zzzv')
  vim.keymap.set('n', '#', '#zzzv')
  vim.keymap.set('n', '<leader> ', 'zz:nohlsearch<cr>', { silent = true })

  -- buffer
  vim.keymap.set('n', '<leader><C-h>', '<cmd>bprevious<cr>')
  vim.keymap.set('n', '<leader><C-l>', '<cmd>bnext<cr>')
  vim.keymap.set('n', '<leader><tab>', '<C-^>')

  --------------------------------
  -- buffer management
  --------------------------------
  vim.keymap.set('n', '<leader>N', '<cmd>enew<cr>')
  vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
  vim.keymap.set('c', 'w!!', 'w !sudo tee > /dev/null %') -- allow saving of files as sudo

  --------------------------------
  -- clipboard
  --------------------------------
  vim.keymap.set('n', 'Y', 'y$') -- fix

  vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p')
  vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P')

  vim.keymap.set('n', '<leader>s', function() require('utils.osc52_yank')(vim.fn.getreg('"')) end) -- sync to system clipboard

  --------------------------------
  -- window
  --------------------------------
  local window = require('utils.window')
  vim.keymap.set({ 'n', 'v', 't' }, '<C-w>H', function() window.resize('H', 2) end)
  vim.keymap.set({ 'n', 'v', 't' }, '<C-w>J', function() window.resize('J', 2) end)
  vim.keymap.set({ 'n', 'v', 't' }, '<C-w>K', function() window.resize('K', 2) end)
  vim.keymap.set({ 'n', 'v', 't' }, '<C-w>L', function() window.resize('L', 2) end)

  vim.keymap.set({ 'n', 'v', 't' }, '<C-w>z', require('utils.zoom').toggle)

  --------------------------------
  -- terminal
  --------------------------------
  vim.keymap.set({ 'n', 'v' }, [[<C-\>]], '<cmd>terminal<cr>')
  vim.keymap.set('n', '<C-w>t', '<cmd>16split | terminal<cr>')
  vim.keymap.set('n', '<C-w>T', '<cmd>vsplit | terminal<cr>')

  --------------------------------
  -- editing
  --------------------------------
  -- Press * to search for the term under the cursor or a visual selection and
  -- then press a key below to replace all instances of it in the current file.
  vim.keymap.set({ 'n', 'x' }, '<leader>R', ':%s///g<left><left>')

  --------------------------------
  -- miscellaneous
  --------------------------------
  vim.keymap.set('n', '<leader>U', require('utils.packer_sync'))
end

map_leader()
apply_key_bindings()
