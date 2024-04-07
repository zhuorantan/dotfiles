return {
  {
    "akinsho/toggleterm.nvim",
    config = true,
    keys = {
      {
        "<C-_>",
        function()
          vim.cmd(string.format('execute v:count . "ToggleTerm dir=%s"', LazyVim.root()))
        end,
        desc = "Terminal (Root Dir)",
      },
      {
        "<leader>tt",
        function()
          vim.cmd(string.format('execute v:count . "ToggleTerm dir=%s"', LazyVim.root()))
        end,
        desc = "Toggle (Root Dir)",
      },
      { "<leader>tT", '<cmd>execute v:count . "ToggleTerm"<cr>', desc = "Toggle (cwd)" },
      { "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle All" },
      { "<leader>ts", "<cmd>TermSelect<cr>", desc = "Select" },
    },
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>fu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
    },
  },
}
