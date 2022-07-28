local hs = hs

local function set_up_clipboard_tool()
  hs.loadSpoon("ClipboardTool")
  spoon.ClipboardTool.hist_size = 2048
  spoon.ClipboardTool.show_copied_alert = false
  spoon.ClipboardTool.show_in_menubar = false
  spoon.ClipboardTool:start()
  spoon.ClipboardTool:bindHotkeys({
    toggle_clipboard = { { 'cmd', 'shift' }, "v" },
  })
end

set_up_clipboard_tool()
