local keymap = vim.keymap

keymap.set("c", "w!!", "w !sudo tee > /dev/null %") -- allow saving of files as sudo

--------------------------------
-- clipboard
--------------------------------
keymap.set({ "n", "v" }, "<leader>pp", '"+p', { desc = "Paste below" })
keymap.set({ "n", "v" }, "<leader>pP", '"+P', { desc = "Paste above" })

keymap.set("n", "<leader>ps", function()
  require("util.osc52_yank")(vim.fn.getreg('""'))
end, { desc = "Sync" })

--------------------------------
-- terminal
--------------------------------
keymap.del("n", "<C-/>")
keymap.del("n", "<leader>ft")
keymap.del("n", "<leader>fT")

keymap.del("t", "<Esc><Esc>")
keymap.set("t", "<Esc>", [[<C-\><C-n>]])

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
