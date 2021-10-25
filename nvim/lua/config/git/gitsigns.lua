local config = {}

function config.after()
  local gitsigns = require('gitsigns')

  gitsigns.setup()
end

return config
