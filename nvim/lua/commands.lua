local vim = vim

local function set_up_commands()
  vim.cmd([[command! PackerSync lua require('utils.packer_sync')]])
end

set_up_commands()
