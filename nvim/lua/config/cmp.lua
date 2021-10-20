local vim = vim

local config = {}

function config.after()
  local cmp = require('cmp')

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
      { name = 'path' },
      { name = 'buffer' },
      { name = 'treesitter' },
      { name = 'nvim_lua' },
    },
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
  }
end

return config
