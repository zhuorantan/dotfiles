local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>u', 'UndotreeToggle')
end

return config
