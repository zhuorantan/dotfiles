return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = "ordinal",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>gs", false },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = "close",
            ["<C-c>"] = { "<esc>", type = "command" },
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>t", group = "terminal" },
      },
    },
  },
  {
    "gbprod/yanky.nvim",
    keys = {
      { "<leader>p", "", desc = "+clipboard" },
      {
        "<leader>ph",
        function()
          require("telescope").extensions.yank_history.yank_history({})
        end,
        desc = "Open Yank History",
      },
    },
  },
  {
    "echasnovski/mini.animate",
    opts = {
      -- disable open and close animations for transparent background
      open = { enable = false },
      close = { enable = false },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        section_separators = { left = "", right = "" },
      },
    },
  },
}
