local markdownlint_config = vim.fn.stdpath("config") .. "/.markdownlint.yaml"

return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "buf" } }, -- protobuf
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters["markdownlint-cli2"] = vim.tbl_deep_extend("force", opts.formatters["markdownlint-cli2"] or {}, {
        prepend_args = { "--config", markdownlint_config },
      })

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({ "markdown", "markdown.mdx" }) do
        local formatters = opts.formatters_by_ft[ft] or {}
        opts.formatters_by_ft[ft] = vim.tbl_filter(function(formatter)
          return formatter ~= "prettier"
        end, formatters)
      end
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", markdownlint_config, "-" },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
      },
    },
  },
}
