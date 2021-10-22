local config = {}

function config.after()
  local bufferline = require('bufferline')
  local bind = require('utils.bind')

  bufferline.setup({
    options = {
      numbers = 'ordinal',
      always_show_bufferline = false,
      show_close_icon = false,
    },
  })

  for i = 1, 9 do
    bind.nmap_cmd('<leader>' .. i, 'BufferLineGoToBuffer ' .. i)
  end
end

return config
