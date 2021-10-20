local vim = vim

local config = {}

function config.after()
  local treesitter = require('nvim-treesitter.configs')

  local languages = { 'comment', 'dockerfile', 'html', 'javascript', 'json', 'json5', 'lua', 'python', 'regex', 'ruby', 'tsx', 'typescript', 'yaml' }

  treesitter.setup({
    ensure_installed = languages,
    highlight = { enable = true },
    -- indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim 
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  })
end

return config
