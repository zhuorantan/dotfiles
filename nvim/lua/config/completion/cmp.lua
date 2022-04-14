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
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = cmp.mapping.confirm { select = true },
      ['<C-c>'] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'path' },
      { name = 'treesitter' },
      { name = 'nvim_lua' },
    }, {
      { name = 'buffer' },
    }),
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    formatting = {
      format = lspkind.cmp_format({
        with_text = true,
        menu = ({
          nvim_lsp = '[LSP]',
          orgmode = '[Org]',
          vsnip = '[VSnip]',
          path = '[Path]',
          treesitter = '[TreeSitter]',
          buffer = '[Buffer]',
          nvim_lua = '[Lua]',
        }),
      }),
    },
  }

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  cmp.setup.filetype('org', {
    sources = cmp.config.sources({
      { name = 'orgmode' },
      { name = 'path' },
      { name = 'treesitter' },
    }, {
      { name = 'buffer' },
    })
  })
end

return config
