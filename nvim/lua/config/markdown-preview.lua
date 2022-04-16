local vim = vim

local M = {}

function M.after()
  vim.g.mkdp_auto_close = 0

  vim.api.nvim_create_augroup('markdown-preview', {})
  vim.api.nvim_create_autocmd('FileType', {
    group = 'markdown-preview',
    pattern = 'markdown',
    callback = function ()
      vim.keymap.set('n', '<leader>md', '<cmd>MarkdownPreviewToggle<cr>', { buffer = true })
    end
  })
end

return M
