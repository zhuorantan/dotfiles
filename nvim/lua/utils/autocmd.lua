local vim = vim

local autocmd = {}

function autocmd.create_augroup(name, commands)
  vim.api.nvim_command('augroup ' .. name)
  vim.api.nvim_command('autocmd!')

  for _, command in ipairs(commands) do 
    vim.api.nvim_command('autocmd ' .. command)
  end

  vim.api.nvim_command('augroup END')
end

return autocmd
