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
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_l = {
              "<c-l>",
              function(self)
                self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
                if self.esc_timer:is_active() then
                  self.esc_timer:start(200, 0, function()
                    vim.schedule(function()
                      vim.cmd.stopinsert()
                      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<c-w>" .. "l", true, false, true))
                    end)
                  end)
                else
                  self.esc_timer:stop()
                  return "<c-l>"
                end
              end,
              mode = "t",
              expr = true,
              desc = "Use <c-l> to navigate to the right window",
            },
          },
        },
      },
    },
  },
}
