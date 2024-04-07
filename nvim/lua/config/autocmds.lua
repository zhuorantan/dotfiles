local function augroup(name)
  return vim.api.nvim_create_augroup("custom_augroup_" .. name, { clear = true })
end

-- Open help vertically
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("help_vert"),
  pattern = "*",
  command = [[if &filetype ==# 'help' | wincmd L | endif]],
})

-- Only show cursor line in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "WinEnter" }, {
  group = augroup("cursor_line_active"),
  pattern = "*",
  command = [[set cursorline]],
})
vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "WinLeave" }, {
  group = augroup("cursor_line_inactive"),
  pattern = "*",
  command = [[set nocursorline]],
})

-- Auto update
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("auto_update"),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false })
    end
  end,
})
