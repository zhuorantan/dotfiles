local vim = vim

local config = {}

function config.after()
  local treesitter = require('nvim-treesitter.configs')

  local languages = { 'comment', 'dockerfile', 'html', 'javascript', 'json', 'json5', 'lua', 'org', 'python', 'regex', 'ruby', 'tsx', 'typescript', 'yaml' }

  treesitter.setup({
    ensure_installed = languages,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
    },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          ["af"] = '@function.outer',
          ["if"] = '@function.inner',
          ["ac"] = '@class.outer',
          ["ic"] = '@class.inner',
        },
      },
    },
    tree_docs = {
      enable = true,
      keymaps = {
        doc_node_at_cursor = '<leader>da',
        doc_all_in_range = '<leader>da',
      },
    },
  })
end

return config
