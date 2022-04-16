local vim = vim

local function set_up_commands()
  vim.api.nvim_create_user_command("PackerSync", function()
    require('utils.packer_sync')()
  end, {})
end

set_up_commands()
