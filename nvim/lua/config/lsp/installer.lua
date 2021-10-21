local config = {}

function config.after()
  local lsp_installer = require('nvim-lsp-installer')
  local lsp_installer_servers = require('nvim-lsp-installer.servers')
  local servers = require('config.lsp.servers')

  for _, server_name in ipairs(servers) do
    local ok, server = lsp_installer_servers.get_server(server_name)

    if ok then
        if not server:is_installed() then
            server:install()
        end
    end
  end

  lsp_installer.on_server_ready(function(server)
    server:setup()

    vim.cmd([[do User LspAttachBuffers]])
  end)
end

return config
