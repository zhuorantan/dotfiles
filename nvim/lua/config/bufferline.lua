local config = {}

function config.after()
  local bufferline = require('bufferline')
  local bind = require('utils.bind')

  bufferline.setup({
    options = {
      numbers = 'ordinal',
      diagnostics = 'nvim_lsp',
      always_show_bufferline = false,
    },
  })

  for i = 1, 9 do
    bind.nmap_cmd('<leader>' .. i, 'BufferLineGoToBuffer ' .. i)
  end
end

return config
