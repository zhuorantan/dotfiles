local global = {}

local function load_variables()
  local home = os.getenv("HOME")
  local os_name = vim.loop.os_uname().sysname

  global.is_mac = os_name == 'Darwin'
  global.is_linux = os_name == 'Linux'
  global.vim_path = vim.fn.stdpath('config')
  global.cache_dir = home .. '/.cache/nvim/'
  global.modules_dir = global.vim_path .. '/modules'
  global.home = home
  global.data_dir = string.format('%s/site/', vim.fn.stdpath('data'))
end

load_variables()

return global
