local config = {}

function config.after()
  local lsp_status = require('lsp-status')
  local lsp_kind = require('lspkind')

  lsp_status.config({
    indicator_errors = '',
    indicator_warnings = '',
    indicator_info = '',
    indicator_hint = '',
    indicator_ok = '',
    kind_labels = lsp_kind.presets.default,
  })
end

return config
