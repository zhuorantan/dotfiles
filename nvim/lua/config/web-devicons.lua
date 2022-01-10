local M = {}

function M.after()
  local web_devicons = require('nvim-web-devicons')

  web_devicons.setup({
    override = {
      c = {
        icon = "",
        color = "#599eff",
        cterm_color = "75",
        name = "c",
      },
      css = {
        icon = "",
        color = "#563d7c",
        cterm_color = "60",
        name = "css",
      },
      Dockerfile = {
        icon = "",
        color = "#384d54",
        cterm_color = "59",
        name = "Dockerfile",
      },
      html = {
        icon = "",
        color = "#e34c26",
        cterm_color = "166",
        name = "html",
      },
      jpeg = {
        icon = "",
        color = "#a074c4",
        cterm_color = "140",
        name = "jpeg",
      },
      jpg = {
        icon = "",
        color = "#a074c4",
        cterm_color = "140",
        name = "jpg",
      },
      js = {
        icon = "",
        color = "#cbcb41",
        cterm_color = "185",
        name = "js",
      },
      kt = {
        icon = "󱈙",
        color = "#f88a02",
        cterm_color = "208",
        name = "kt",
      },
      lock = {
        icon = "",
        color = "#ff0000",
        cterm_color = "9",
        name = "lock",
      },
      out = {
        icon = "",
        color = "#ffffff",
        cterm_color = "15",
        name = "out",
      },
      png = {
        icon = "",
        color = "#a074c4",
        cterm_color = "140",
        name = "png",
      },
      ["robots.txt"] = {
        icon = "ﮧ",
        color = "#ff0000",
        cterm_color = "9",
        name = "robots",
      },
      ts = {
        icon = "ﯤ",
        color = "#519aba",
        cterm_color = "67",
        name = "ts",
      },
      ttf = {
        icon = "",
        color = "#ffffff",
        cterm_color = "15",
        name = "TrueTypeFont",
      },
      rb = {
        icon = "",
        color = "#701516",
        cterm_color = "52",
        name = "rb",
      },
      woff = {
        icon = "",
        color = "#ffffff",
        cterm_color = "15",
        name = "WebOpenFontFormat",
      },
      woff2 = {
        icon = "",
        color = "#ffffff",
        cterm_color = "15",
        name = "WebOpenFontFormat2",
      },
      xz = {
        icon = "",
        color = "#cbcb41",
        cterm_color = "185",
        name = "xz",
      },
      zip = {
        icon = "",
        color = "#cbcb41",
        cterm_color = "185",
        name = "zip",
      },
    },
    default = true,
  })
end

return M
