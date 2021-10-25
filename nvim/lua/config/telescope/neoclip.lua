local config = {}

function config.after()
  local neoclip = require('neoclip')

  neoclip.setup()
end

return config
