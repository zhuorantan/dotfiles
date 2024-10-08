return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "swift" },
      },
      servers = {
        sourcekit = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
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
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "swift" },
    },
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("xcodebuild").setup({})
    end,
    ft = { "swift" },
    keys = {
      { "<leader>ii", "<cmd>XcodebuildPicker<cr>", ft = "swift", desc = "Show Xcodebuild Actions" },
      { "<leader>if", "<cmd>XcodebuildProjectManager<cr>", ft = "swift", desc = "Show Project Manager Actions" },
      { "<leader>ib", "<cmd>XcodebuildBuild<cr>", ft = "swift", desc = "Build Project" },
      { "<leader>iB", "<cmd>XcodebuildBuildForTesting<cr>", ft = "swift", desc = "Build For Testing" },
      { "<leader>ir", "<cmd>XcodebuildBuildRun<cr>", ft = "swift", desc = "Build & Run Project" },
      { "<leader>iR", "<cmd>XcodebuildRun<cr>", ft = "swift", desc = "Run Project" },
      { "<leader>it", "<cmd>XcodebuildTest<cr>", ft = "swift", desc = "Run Tests" },
      { "<leader>it", "<cmd>XcodebuildTestSelected<cr>", ft = "swift", desc = "Run Selected Tests", mode = "v" },
      { "<leader>iT", "<cmd>XcodebuildTestClass<cr>", ft = "swift", desc = "Run Current Test Class" },
      { "<leader>i.", "<cmd>XcodebuildTestRepeat<cr>", ft = "swift", desc = "Repeat Last Test Run" },
      { "<leader>il", "<cmd>XcodebuildToggleLogs<cr>", ft = "swift", desc = "Toggle Xcodebuild Logs" },
      { "<leader>ic", "<cmd>XcodebuildToggleCodeCoverage<cr>", ft = "swift", desc = "Toggle Code Coverage" },
      { "<leader>iC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", ft = "swift", desc = "Show Code Coverage Report" },
      { "<leader>ie", "<cmd>XcodebuildTestExplorerToggle<cr>", ft = "swift", desc = "Toggle Test Explorer" },
      { "<leader>is", "<cmd>XcodebuildFailingSnapshots<cr>", ft = "swift", desc = "Show Failing Snapshots" },
      { "<leader>id", "<cmd>XcodebuildSelectDevice<cr>", ft = "swift", desc = "Select Device" },
      { "<leader>ip", "<cmd>XcodebuildSelectTestPlan<cr>", ft = "swift", desc = "Select Test Plan" },
      { "<leader>ix", "<cmd>XcodebuildQuickfixLine<cr>", ft = "swift", desc = "Quickfix Line" },
      { "<leader>ia", "<cmd>XcodebuildCodeActions<cr>", ft = "swift", desc = "Show Code Actions" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>i", group = "xcode" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    ft = { "swift" },
    opts = function(_, opts)
      table.insert(opts.sections.lualine_c, { "' ' .. vim.g.xcodebuild_last_status", color = { fg = "Gray" } })
      table.insert(opts.sections.lualine_c, {
        function()
          if vim.g.xcodebuild_platform == "macOS" then
            return " macOS"
          end

          local deviceIcon = ""
          if vim.g.xcodebuild_platform:match("watch") then
            deviceIcon = "􀟤"
          elseif vim.g.xcodebuild_platform:match("tv") then
            deviceIcon = "􀡴 "
          elseif vim.g.xcodebuild_platform:match("vision") then
            deviceIcon = "􁎖 "
          end

          if vim.g.xcodebuild_os then
            return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
          end

          return deviceIcon .. " " .. vim.g.xcodebuild_device_name
        end,
        color = { fg = "#f9e2af", bg = "#161622" },
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "codelldb" } },
  },
  {
    "mfussenegger/nvim-dap",
    ft = { "swift" },
    opts = function()
      local xcodebuild = require("xcodebuild.integrations.dap")
      xcodebuild.setup("codelldb")
    end,
    keys = {
      {
        "<leader>dd",
        function()
          require("xcodebuild.integrations.dap").build_and_debug()
        end,
        ft = "swift",
        desc = "Build & Debug",
      },
      {
        "<leader>dD",
        function()
          require("xcodebuild.integrations.dap").debug_without_build()
        end,
        ft = "swift",
        desc = "Debug Without Build",
      },
      {
        "<leader>db",
        function()
          require("xcodebuild.integrations.dap").toggle_breakpoint()
        end,
        ft = "swift",
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dt",
        function()
          require("xcodebuild.integrations.dap").terminate_session()
        end,
        ft = "swift",
        desc = "Terminate",
      },
    },
  },
}
