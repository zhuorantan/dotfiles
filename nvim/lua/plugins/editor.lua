return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
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
      { "<leader>gs", "<cmd>Git<cr>", desc = "Status" },
      { "<leader>gg", "<cmd>Git log<cr>", desc = "Log" },
      { "<leader>gb", "<cmd>Git blame<cr>", { "n", "v" }, desc = "Blame" },
      { "<leader>gx", "<cmd>GBrowse<cr>", { "n", "v" }, desc = "Browse" },
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
