local config = {}

function config.after()
  local lsp_status = require('lsp-status')

  lsp_status.config({
    indicator_errors = '',
    indicator_warnings = '',
    indicator_info = '',
    indicator_hint = '',
    indicator_ok = '',
  })
end

return config
