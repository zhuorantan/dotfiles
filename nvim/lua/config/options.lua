local opt = vim.opt

opt.hidden = true
opt.secure = true

opt.smarttab = true
opt.softtabstop = 2

opt.clipboard = ""

opt.number = false
opt.relativenumber = false

opt.list = false
opt.mouse = "nvi"

-- remove root detection based on lsp since it keeps jumping into workspaces
vim.g.root_spec = { { ".git", "lua" }, "cwd" }
