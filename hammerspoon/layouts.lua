local hs = hs

-- Window layout
local function layoutApps()
  local apps = require('apps')
  local screens = hs.screen.allScreens()

  local layout = {}

  table.insert(layout, { "Alacritty", nil, screens[1], hs.layout.maximized, nil, nil })
  table.insert(layout, { apps.xcodeAppName, nil, screens[1], hs.layout.maximized, nil, nil })
  table.insert(layout, { "Simulator", nil, screens[1], hs.layout.right25, nil, nil })

  table.insert(layout, { "Music", nil, screens[1], { x = 0.05, y = 0.1, w = 0.55, h = 0.8 }, nil, nil })
  table.insert(layout, { apps.browserAppName, nil, screens[1], hs.layout.left75, nil, nil })

  if screens[1]:fullFrame().w < 1920 then
    table.insert(layout, { "Messages", nil, screens[1], { x = 0.2, y = 0.1, w = 0.6, h = 0.8 }, nil, nil })
    table.insert(layout, { "Telegram", nil, screens[1], { x = 0.2, y = 0.1, w = 0.6, h = 0.8 }, nil, nil })
    table.insert(layout, { "WeChat", nil, screens[1], { x = 0.2, y = 0.1, w = 0.6, h = 0.8 }, nil, nil })
  else
    table.insert(layout, { "Messages", nil, screens[1], { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil })
    table.insert(layout, { "Telegram", nil, screens[1], { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil })
    table.insert(layout, { "WeChat", nil, screens[1], { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil })
  end

  table.insert(layout, { "Microsoft Outlook", nil, screens[2], hs.layout.maximized, nil, nil })
  table.insert(layout, { "Microsoft Teams", nil, screens[1], { x = 0.15, y = 0.05, w = 0.7, h = 0.9 }, nil, nil })

  hs.layout.apply(layout)
end

return layoutApps
