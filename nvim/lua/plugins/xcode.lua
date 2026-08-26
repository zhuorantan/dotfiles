if vim.fn.has("macunix") ~= 1 then
  return {}
end

local function xcodebuild_device()
  local platform = vim.g.xcodebuild_platform or ""

  if platform == "macOS" then
    return " macOS"
  end

  local icon = ""
  if platform:match("watch") then
    icon = "􀗤"
  elseif platform:match("tv") then
    icon = "􀓴"
  elseif platform:match("vision") then
    icon = "􁎖"
  end

  local device = vim.g.xcodebuild_device_name or platform
  local os = vim.g.xcodebuild_os
  return os and string.format("%s %s (%s)", icon, device, os) or string.format("%s %s", icon, device)
end

local function apply_xcode_27_destination_fix()
  local util = require("xcodebuild.util")
  local xcode = require("xcodebuild.core.xcode")

  -- Xcode 27 renamed "Available destinations" to "Destinations compatible with".
  -- Remove this override once xcodebuild.nvim recognizes the new heading upstream.
  xcode.get_destinations = function(project_file, scheme, working_directory, callback)
    local command = { "xcodebuild" }

    if project_file then
      table.insert(command, project_file:match("%.xcodeproj$") and "-project" or "-workspace")
      table.insert(command, project_file)
    end

    vim.list_extend(command, { "-showdestinations", "-scheme", scheme })

    return vim.fn.jobstart(command, {
      stdout_buffered = true,
      cwd = working_directory,
      on_stdout = function(_, output)
        local destinations = {}
        local found_destinations = false
        local value_pattern = ":%s*([^@}]-)%s*[@}]"

        for _, line in ipairs(output) do
          local trimmed_line = util.trim(line)

          if found_destinations and trimmed_line == "" then
            break
          elseif found_destinations and vim.startswith(trimmed_line, "{") then
            local sanitized_line = trimmed_line:gsub(", ", "@")
            local destination = {
              platform = sanitized_line:match("platform" .. value_pattern),
              variant = sanitized_line:match("variant" .. value_pattern),
              arch = sanitized_line:match("arch" .. value_pattern),
              id = sanitized_line:match("id" .. value_pattern),
              name = sanitized_line:match("name" .. value_pattern),
              os = sanitized_line:match("OS" .. value_pattern),
              error = sanitized_line:match("error" .. value_pattern),
            }

            if destination.platform and destination.id and destination.name then
              table.insert(destinations, destination)
            end
          elseif
            trimmed_line:find("Available destinations", 1, true)
            or trimmed_line:find("Destinations compatible with", 1, true)
          then
            found_destinations = true
          end
        end

        callback(destinations)
      end,
    })
  end
end

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "swiftlint",
        "xcbeautify",
        "xcode-build-server",
        "xcodeprojectcli",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swift" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          cmd = { "xcrun", "sourcekit-lsp" },
          filetypes = { "swift" },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local components = {
        {
          function()
            return " " .. vim.g.xcodebuild_last_status
          end,
          cond = function()
            return vim.g.xcodebuild_last_status ~= nil
          end,
          color = { fg = "Gray" },
        },
        {
          function()
            return "󰙨 " .. vim.g.xcodebuild_test_plan
          end,
          cond = function()
            return vim.g.xcodebuild_test_plan ~= nil
          end,
          color = { fg = "#a6e3a1" },
        },
        {
          xcodebuild_device,
          cond = function()
            return vim.g.xcodebuild_device_name ~= nil or vim.g.xcodebuild_platform ~= nil
          end,
          color = { fg = "#f9e2af" },
        },
      }

      for index = #components, 1, -1 do
        table.insert(opts.sections.lualine_x, 1, components[index])
      end
    end,
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    ft = "swift",
    cmd = { "XcodebuildSetup" },
    dependencies = {
      "folke/snacks.nvim",
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      restore_on_start = false,
      integrations = {
        xcode_build_server = {
          enabled = true,
        },
        pymobiledevice = {
          enabled = true,
        },
      },
    },
    config = function(_, opts)
      require("xcodebuild").setup(opts)
      require("xcodebuild.integrations.dap").setup()
      apply_xcode_27_destination_fix()
    end,
    keys = {
      { "<leader>is", "<cmd>XcodebuildSetup<cr>", desc = "Setup Xcode Project" },
      { "<leader>ia", "<cmd>XcodebuildPicker<cr>", desc = "Show Xcodebuild Actions" },
      { "<leader>ib", "<cmd>XcodebuildBuild<cr>", desc = "Build Project" },
      { "<leader>ir", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run Project" },
      { "<leader>it", "<cmd>XcodebuildTestNearest<cr>", desc = "Run Nearest Test" },
      { "<leader>iT", "<cmd>XcodebuildTest<cr>", desc = "Run All Tests" },
      { "<leader>il", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Xcodebuild Logs" },
      { "<leader>id", "<cmd>XcodebuildBuildDebug<cr>", desc = "Build & Debug Project" },
      { "<leader>iD", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
      { "<leader>ic", "<cmd>XcodebuildCancel<cr>", desc = "Cancel Xcodebuild Action" },
    },
  },
}
