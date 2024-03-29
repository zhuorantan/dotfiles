local vim = vim

local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr)
  local fzf_lua = require('fzf-lua')
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gd', function () fzf_lua.lsp_definitions({ jump_to_single_result = true }) end, { buffer = bufnr })
  vim.keymap.set('n', 'gD', function () fzf_lua.lsp_declarations({ jump_to_single_result = true }) end, { buffer = bufnr })
  vim.keymap.set('n', 'gt', function () fzf_lua.lsp_typedefs({ jump_to_single_result = true }) end, { buffer = bufnr })
  vim.keymap.set('n', 'gi', function () fzf_lua.lsp_implementations({ jump_to_single_result = true }) end, { buffer = bufnr })
  vim.keymap.set('n', 'gr', function () fzf_lua.lsp_references({ jump_to_single_result = true }) end, { buffer = bufnr })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
  vim.keymap.set('n', '<leader>ca', fzf_lua.lsp_code_actions, { buffer = bufnr })
  vim.keymap.set('n', '<leader>F', function () vim.lsp.buf.format({ async = true }) end, { buffer = bufnr })

  if client.server_capabilities.document_highlight then
    vim.api.nvim_create_augroup('lsp-highlight', {})
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = 'lsp-highlight',
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = 'lsp-highlight',
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

function M.after()
  local lsp_installer = require('nvim-lsp-installer')
  local lspconfig = require('lspconfig')
  local cmp_lsp = require('cmp_nvim_lsp')
  local server_config = require('config.lsp.servers')

  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

  lsp_installer.setup({
    automatic_installation = true,
  })

  local lsp_signature = require('lsp_signature')
  lsp_signature.setup({
    hint_enable = false,
  })

  local capabilities = cmp_lsp.default_capabilities()

  for _, server_name in pairs(server_config.servers) do
    local config = {
      on_attach = on_attach,
      capabilities = capabilities,
    }

    for k, v in pairs(server_config.configs[server_name] or {}) do
      config[k] = v
    end

    lspconfig[server_name].setup(config)

    vim.cmd([[do User LspAttachBuffers]])
  end
end

return M
