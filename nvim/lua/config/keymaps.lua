local keymap = vim.keymap

keymap.set("c", "w!!", "w !sudo tee > /dev/null %") -- allow saving of files as sudo

--------------------------------
-- clipboard
--------------------------------
keymap.set("n", "<leader>ps", function()
  require("util.osc52_yank")(vim.fn.getreg('""'))
end, { desc = "Sync" })

--------------------------------
-- terminal
--------------------------------
keymap.set("n", "<C-\\>", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })
keymap.set("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap.set("n", "<C-_>", function()
  Snacks.terminal("codex", { win = { position = "right", width = 0.4 } })
end, { desc = "Codex" })

--------------------------------
-- bufferline
--------------------------------
for i = 1, 9 do
  keymap.set(
    "n",
    string.format("<leader>%d", i),
    string.format("<cmd>BufferLineGoToBuffer %d<cr>", i),
    { desc = "which_key_ignore" }
  )
end

--------------------------------
-- buffer delete
--------------------------------
keymap.set("n", "<C-q>", function()
  require("util.sayonara")(false)
end, { desc = "Close Buffer" })
keymap.set("n", "<leader><C-q>", function()
  require("util.sayonara")(true)
end, { desc = "Delete Buffer" })
