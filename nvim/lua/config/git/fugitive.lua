local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>gs', 'Git')
  bind.nmap_cmd('<leader>gg', 'Git log')
  bind.nmap_cmd('<leader>gb', 'Git blame')
  bind.vmap_cmd('<leader>gb', 'Git blame')
  bind.nmap_cmd('<leader>gd', 'Gdiffsplit')

  bind.nmap_cmd('<leader>ga', 'Git add %:p')
  bind.nmap_cmd('<leader>gc', 'Git commit -q')
  bind.nmap_cmd('<leader>gm', 'Git merge')
  bind.nmap_cmd('<leader>gf', 'Dispatch Git fetch --quiet')
  bind.nmap_cmd('<leader>gl', 'Dispatch Git pull --quiet')
  bind.nmap_cmd('<leader>gp', 'Dispatch Git push --quiet')
  bind.nmap_cmd('<leader>gP', 'Dispatch Git push --force --quiet')
end

return config
