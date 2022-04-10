local M = {}

function M.after()
  local orgmode = require('orgmode')
  local treesitter = require('nvim-treesitter.configs')

  orgmode.setup_ts_grammar()

  treesitter.setup({
    -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
    highlight = {
      enable = true,
      disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
      additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
    },
    ensure_installed = {'org'}, -- Or run :TSUpdate org
  })

  orgmode.setup({
    org_agenda_files = {'~/Documents/org/*'},
    org_default_notes_file = '~/Documents/org/refile.org',
  })
end

return M
