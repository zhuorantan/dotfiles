return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = function(opts)
          local total_buffers = #vim.tbl_filter(function(buf)
            return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
          end, vim.api.nvim_list_bufs())
          return total_buffers - opts.ordinal + 1
        end,
        sort_by = function(buffer_a, buffer_b)
          return buffer_a.id > buffer_b.id
        end,
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
      picker = {
        sources = {
          explorer = {
            auto_close = true,
          },
        },
      },
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
