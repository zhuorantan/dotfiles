return {
  {
    "mason-org/mason.nvim",
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
