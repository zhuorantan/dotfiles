local M = {}

function M.after()
  local dlsconfig = require('diagnosticls-configs')
  local swiftlint = require('diagnosticls-configs.linters.swiftlint')

  dlsconfig.init()
  dlsconfig.setup({
    swift = {
      linter = swiftlint,
    }
  })
end

return M
