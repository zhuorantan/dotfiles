local vim = vim

local config = {}

function config.after()
  local lsp_status = require('lsp-status')
  local nvim_lsp = require('lspconfig')
  local cmp_lsp = require('cmp_nvim_lsp')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local function on_attach(client, bufnr)
    local function buf_map_cmd(mode, lhs, cmd)
      local rhs = string.format(':lua %s<CR>', cmd)
      local options = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
    end

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_map_cmd('n', 'gd', 'vim.lsp.buf.definition()')
    buf_map_cmd('n', 'gD', 'vim.lsp.buf.declaration()')
    buf_map_cmd('n', 'gt', 'vim.lsp.buf.type_definition()')
    buf_map_cmd('n', 'gi', 'vim.lsp.buf.implementation()')
    buf_map_cmd('n', 'gr', 'vim.lsp.buf.references()')
    buf_map_cmd('n', 'K', 'vim.lsp.buf.hover()')
    buf_map_cmd('n', '<C-k>', 'vim.lsp.buf.signature_help()')
    -- buf_map_cmd('n', '<leader>wa', 'vim.lsp.buf.add_workspace_folder()')
    -- buf_map_cmd('n', '<leader>wr', 'vim.lsp.buf.remove_workspace_folder()')
    -- buf_map_cmd('n', '<leader>wl', 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))')
    buf_map_cmd('n', '<leader>rn', 'vim.lsp.buf.rename()')
    buf_map_cmd('n', '<leader>ca', 'vim.lsp.buf.code_action()')
    buf_map_cmd('n', '<leader>e', 'vim.lsp.diagnostic.show_line_diagnostics()')
    buf_map_cmd('n', '[d', 'vim.lsp.diagnostic.goto_prev()')
    buf_map_cmd('n', ']d', 'vim.lsp.diagnostic.goto_next()')
    buf_map_cmd('n', '<leader>d', 'vim.lsp.diagnostic.set_loclist()')
    buf_map_cmd('v', '<leader>f', 'vim.lsp.buf.range_formatting()')
    buf_map_cmd('n', '<leader>f', 'vim.lsp.buf.range_formatting()')
    buf_map_cmd('n', '<leader>F', 'vim.lsp.buf.formatting()')

    -- Register client for messages and set up buffer autocommands to update 
    -- the statusline and the current function.
    -- NOTE: on_attach is called with the client object, which is the "client" parameter below
    if lsp_status then
      lsp_status.on_attach(client)
    end
  end

  -- Register the progress handler
  if lsp_status then
    lsp_status.register_progress()
  end
  -- Set default client capabilities plus window/workDoneProgress
  -- config.capabilities = vim.tbl_extend('keep', config.capabilities or {}, lsp_status.capabilities)

  local servers = { 'clangd', 'cmake', 'cssls', 'dockerls', 'html', 'jsonls', 'solargraph', 'sourcekit', 'pyright', 'tsserver' }

  local capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
    }
  end
end

return config
