return {
  {
    "APZelos/blamer.nvim",
    event = "VeryLazy",
    config = function()
      vim.g.blamer_enabled = true
      vim.g.blamer_delay = 500
      vim.g.blamer_relative_time = true
    end,
  },
  {
    "junegunn/gv.vim",
    dependencies = { "tpope/vim-fugitive" },
    cmd = "GV",
    keys = {
      { "<leader>gv", "<cmd>GV --all<cr>", desc = "GV" },
      { "<leader>gV", "<cmd>GV<cr>", desc = "GV (current branch)" },
    },
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "Gdiffsplit", "GBrowse" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Fugitive" },
      { "<leader>gb", "<cmd>Git blame<cr>", { "n", "v" }, desc = "Blame" },
      { "<leader>gf", "<cmd>Dispatch git fetch<cr>", desc = "Fetch" },
      { "<leader>gl", "<cmd>Dispatch git pull --quiet<cr>", desc = "Pull" },
      { "<leader>gp", "<cmd>Dispatch git push --quiet<cr>", desc = "Push" },
      { "<leader>gP", "<cmd>Dispatch git push --quiet --force<cr>", desc = "Force Push" },
    },
  },
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },
  {
    "mhinz/vim-sayonara",
    keys = {
      { "<C-q>", "<cmd>Sayonara<cr>", desc = "Sayonara" },
      { "<leader><C-q>", "<cmd>Sayonara!<cr>", desc = "Sayonara" },
    },
    init = function()
      vim.g.sayonara_confirm_quit = 1
    end,
  },
  {
    "tpope/vim-sleuth",
    event = "VeryLazy",
  },
  {
    "tpope/vim-unimpaired",
    event = "VeryLazy",
  },
}
