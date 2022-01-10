local config = {}

function config.after()
  local lsp_status = require('lsp-status')
  local lsp_kind = require('lspkind')

  lsp_status.config({
    kind_labels = lsp_kind.presets.default,
  })
end

return config
