local hs = hs

local hyper = require('keybindings').hyper

local function set_up_clipboard_tool()
  hs.loadSpoon("ClipboardTool")
  spoon.ClipboardTool.hist_size = 2048
  spoon.ClipboardTool.show_copied_alert = false
  spoon.ClipboardTool.show_in_menubar = false
  spoon.ClipboardTool:start()
  spoon.ClipboardTool:bindHotkeys({
    toggle_clipboard = { hyper, "v" },
  })
end

set_up_clipboard_tool()
