local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>gv', 'GV --all')
  bind.nmap_cmd('<leader>gV', 'GV')
end

return config
