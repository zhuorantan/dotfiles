return {
  not vim.env.ZT_WORK
      and {
        "greggh/claude-code.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim", -- Required for git operations
        },
        config = function()
          require("claude-code").setup({
            window = { position = "vertical" },
            keymaps = {
              toggle = {
                normal = false,
                terminal = false,
              },
              scrolling = false,
            },
          })
        end,
        keys = {
          { "<leader><C-\\>", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
        },
      }
    or {},
}
