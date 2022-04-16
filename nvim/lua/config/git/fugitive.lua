local vim = vim

local M = {}

function M.before()
  vim.g.fugitive_azure_devops_baseurl = 'office.visualstudio.com'

  vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>')
  vim.keymap.set('n', '<leader>gg', '<cmd>Git log<cr>')
  vim.keymap.set({ 'n', 'v' }, '<leader>gb', '<cmd>Git blame<cr>')
  vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>')
  vim.keymap.set({ 'n', 'v' }, '<leader>gx', '<cmd>GBrowse<cr>')

  vim.keymap.set('n', '<leader>ga', '<cmd>Git add %:p<cr>')
  vim.keymap.set('n', '<leader>gc', '<cmd>Git commit -q<cr>')
  vim.keymap.set('n', '<leader>gm', '<cmd>Git merge<cr>')
  vim.keymap.set('n', '<leader>gf', '<cmd>Dispatch git fetch<cr>')
  vim.keymap.set('n', '<leader>gl', '<cmd>Dispatch git pull --quiet<cr>')
  vim.keymap.set('n', '<leader>gp', '<cmd>Dispatch git push --quiet<cr>')
  vim.keymap.set('n', '<leader>gP', '<cmd>Dispatch git push --force --quiet<cr>')
end

return M
