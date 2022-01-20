local vim = vim

local config = {}

function config.after()
  local autocmd = require('utils.autocmd')

  vim.g.mkdp_auto_close = 0
  autocmd.create_augroup('markdown_preview', {
    [[FileType markdown nnoremap <buffer><silent> <leader>md :MarkdownPreviewToggle<CR>]],
  })
end

return config
