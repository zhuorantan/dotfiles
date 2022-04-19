local vim = vim

local M = {}

function M.resize(direction, resize_count)
  if vim.fn.winnr() <= 1 then
    return
  end

  local is_last_win = vim.fn.winnr() == vim.fn.winnr('$')

  local modifier
  if direction == 'H' or direction == 'K' then
    modifier = is_last_win and '+' or '-'
  else
    modifier = is_last_win and '-' or '+'
  end

  local command
  if direction == 'H' or direction == 'L' then
    command = 'vertical resize'
  else
    command = 'resize'
  end

  local cmd = string.format('%s %s%d', command, modifier, resize_count)
  vim.cmd(cmd)

  local timer
  vim.keymap.set({ 'n' , 'v', 't' }, direction, function()
    vim.cmd(cmd)

    if timer then
      timer:close()
    end

    timer = vim.defer_fn(function()
      vim.keymap.del({ 'n' , 'v', 't' }, direction, { buffer = true })
      timer = nil
    end, 500)
  end, { buffer = true })
end

return M
