local M = {}

function M.toggle()
  if vim.fn.winnr("$") == 1 then
    return
  end

  if vim.t.zoom_restore then
    vim.fn.execute(vim.t.zoom_restore)
    vim.t.zoom_restore = nil
  else
    vim.t.zoom_restore = vim.fn.winrestcmd()
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
  end
end

return M
