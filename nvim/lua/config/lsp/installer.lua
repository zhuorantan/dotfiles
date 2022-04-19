local vim = vim

local M = {}

function M.after()
  local lsp_installer = require('nvim-lsp-installer')
  local cmp_lsp = require('cmp_nvim_lsp')
  local server_config = require('config.lsp.servers')

  local function ensure_servers_installed()
    local lsp_installer_servers = require('nvim-lsp-installer.servers')

    for _, server_name in ipairs(server_config.servers) do
      local ok, server = lsp_installer_servers.get_server(server_name)

      if ok then
          if not server:is_installed() then
              server:install()
          end
      end
    end
  end

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local function on_attach(client, bufnr)
    local fzf_lua = require('fzf-lua')
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gd', function () fzf_lua.lsp_definitions({ jump_to_single_result = true }) end, { buffer = true })
    vim.keymap.set('n', 'gD', function () fzf_lua.lsp_declarations({ jump_to_single_result = true }) end, { buffer = true })
    vim.keymap.set('n', 'gt', function () fzf_lua.lsp_typedefs({ jump_to_single_result = true }) end, { buffer = true })
    vim.keymap.set('n', 'gi', function () fzf_lua.lsp_implementations({ jump_to_single_result = true }) end, { buffer = true })
    vim.keymap.set('n', 'gr', function () fzf_lua.lsp_references({ jump_to_single_result = true }) end, { buffer = true })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = true })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = true })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = true })
    vim.keymap.set('n', '<leader>ca', fzf_lua.lsp_code_actions, { buffer = true })
    vim.keymap.set('n', '<leader>e', vim.lsp.diagnostic.show_line_diagnostics, { buffer = true })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = true })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = true })
    vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.range_formatting, { buffer = true })
    vim.keymap.set('n', '<leader>F', vim.lsp.buf.formatting, { buffer = true })

    if client.resolved_capabilities.document_highlight then
      vim.api.nvim_create_augroup('lsp-highlight', {})
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = 'lsp-highlight',
        buffer = 0,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        group = 'lsp-highlight',
        buffer = 0,
        callback = vim.lsp.buf.clear_references,
      })
    end

    local lsp_signature = require('lsp_signature')
    lsp_signature.on_attach()
  end

  ensure_servers_installed()

  local capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  lsp_installer.on_server_ready(function(server)
    local config = {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
    }
    for k, v in pairs(server_config.configs[server.name] or {}) do
      config[k] = v
    end

    server:setup(config)

    vim.cmd([[do User LspAttachBuffers]])
  end)
end

return M
