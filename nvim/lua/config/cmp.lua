local vim = vim

local config = {}

function config.after()
  local cmp = require('cmp')
  local lspkind = require('lspkind')

  cmp.setup {
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<C-c>'] = cmp.mapping.complete(),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'path' },
      { name = 'treesitter' },
      { name = 'buffer' },
      { name = 'nvim_lua' },
    },
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    formatting = {
      format = lspkind.cmp_format({
        with_text = true,
        menu = ({
          nvim_lsp = '[LSP]',
          vsnip = '[VSnip]',
          path = '[Path]',
          treesitter = '[TreeSitter]',
          buffer = '[Buffer]',
          nvim_lua = '[Lua]',
        }),
      }),
    },
  }
end

return config
