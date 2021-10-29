local vim = vim

local bind = {}

local function map(mode, lhs, rhs, options)
  if options == nil then
    options = {}
  end
  if options.noremap == nil then
    options.noremap = true
  end

  if options.buffer ~= nil then
    vim.api.nvim_buf_set_keymap(options.buffer, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

local function map_cmd(mode, lhs, cmd, options)
  if options == nil then
    options = {}
  end
  if options.silent == nil then
    options.silent = true
  end

  local rhs = string.format(':%s<CR>', cmd)
  map(mode, lhs, rhs, options)
end

function bind.nmap(lhs, rhs, options)
  map('n', lhs, rhs, options)
end

function bind.vmap(lhs, rhs, options)
  map('v', lhs, rhs, options)
end

function bind.cmap(lhs, rhs, options)
  map('c', lhs, rhs, options)
end

function bind.xmap(lhs, rhs, options)
  map('x', lhs, rhs, options)
end

function bind.nmap_cmd(lhs, cmd, options)
  map_cmd('n', lhs, cmd, options)
end

function bind.vmap_cmd(lhs, cmd, options)
  map_cmd('v', lhs, cmd, options)
end

function bind.xmap_cmd(lhs, cmd, options)
  map_cmd('x', lhs, cmd, options)
end

return bind
