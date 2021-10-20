local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>q', 'Sayonara')
  bind.nmap_cmd('<leader>Q', 'Sayonara!')
end

return config
