vim.filetype.add({
  extension = {
    bean = "beancount",
    beancount = "beancount",
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "beancount" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "beancount-language-server" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        beancount = {
          root_markers = { "main.beancount", ".git" },
          before_init = function(params, config)
            if not config.root_dir then
              return
            end
            params.initializationOptions = params.initializationOptions or {}
            params.initializationOptions.journal_file = vim.fs.joinpath(config.root_dir, "main.beancount")
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        beancount = { "bean-format" },
      },
    },
  },
}
