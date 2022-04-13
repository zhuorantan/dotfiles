local vim = vim

local config = {}

function config.before()
  vim.g.fugitive_azure_devops_baseurl = 'office.visualstudio.com'

  local bind = require('utils.bind')

  bind.nmap_cmd('<leader>gs', 'Git')
  bind.nmap_cmd('<leader>gg', 'Git log')
  bind.nmap_cmd('<leader>gb', 'Git blame')
  bind.vmap_cmd('<leader>gb', 'Git blame')
  bind.nmap_cmd('<leader>gd', 'Gdiffsplit')
  bind.nmap_cmd('<leader>gx', 'GBrowse')
  bind.vmap_cmd('<leader>gx', 'GBrowse')

  bind.nmap_cmd('<leader>ga', 'Git add %:p')
  bind.nmap_cmd('<leader>gc', 'Git commit -q')
  bind.nmap_cmd('<leader>gm', 'Git merge')
  bind.nmap_cmd('<leader>gf', 'Dispatch git fetch')
  bind.nmap_cmd('<leader>gl', 'Dispatch git pull --quiet')
  bind.nmap_cmd('<leader>gp', 'Dispatch git push --quiet')
  bind.nmap_cmd('<leader>gP', 'Dispatch git push --force --quiet')
end

return config
