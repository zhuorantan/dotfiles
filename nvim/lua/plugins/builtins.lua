return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
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
    "hrsh7th/nvim-cmp",
    opts = {
      enabled = function()
        return not vim.g.cmp_disabled
      end,
    },
    keys = {
      {
        "<leader>ck",
        function()
          vim.g.cmp_disabled = not vim.g.cmp_disabled
          vim.notify("Completion " .. (vim.g.cmp_disabled and "disabled" or "enabled"))
        end,
        desc = "Toggle completion",
      },
    },
  },
}
