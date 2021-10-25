local config = {}

function config.after()
  local filetype = require('filetype')

  filetype.setup({
    overrides = {
      literal = {
        ['tmux.conf'] = 'tmux',
      },
    },
  })
end

return config
