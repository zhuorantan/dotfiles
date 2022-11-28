local vim = vim

local M = {}

function M.after()
  vim.keymap.set('n', '<leader>v', function ()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)

    if venn_enabled == 'nil' then
      vim.b.venn_enabled = true
      vim.cmd([[setlocal ve=all]])
      -- draw a line on HJKL keystokes
      vim.keymap.set('n', 'J', '<C-v>j:VBox<CR>', { buffer = true })
      vim.keymap.set('n', 'K', '<C-v>k:VBox<CR>', { buffer = true })
      vim.keymap.set('n', 'L', '<C-v>l:VBox<CR>', { buffer = true })
      vim.keymap.set('n', 'H', '<C-v>h:VBox<CR>', { buffer = true })
      -- draw a box by pressing "f" with visual selection
      vim.keymap.set('v', 'f', ':VBox<CR>', { buffer = true })
    else
      vim.cmd([[setlocal ve=]])
      vim.keymap.del('n', 'J', { buffer = true })
      vim.keymap.del('n', 'K', { buffer = true })
      vim.keymap.del('n', 'L', { buffer = true })
      vim.keymap.del('n', 'H', { buffer = true })
      vim.keymap.del('v', 'f', { buffer = true })
      vim.b.venn_enabled = nil
    end
  end)
end

return M
