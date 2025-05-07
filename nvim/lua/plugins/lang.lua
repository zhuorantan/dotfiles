return {
  { "mason-org/mason-lspconfig.nvim", version = "1.32.0" },
  {
    "williamboman/mason.nvim",
    version = "1.11.0",
    opts = { ensure_installed = { "buf" } }, -- protobuf
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
