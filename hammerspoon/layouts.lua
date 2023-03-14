local hs = hs

-- Window layout
local function layoutApps()
  local devices = require('devices')
  local apps = require('apps')
  local primaryScreen = hs.screen { x = 0, y = 0 }
  local secondaryScreen = hs.screen { x = 0, y = -1 }

  local windowLayout

  if devices.current == devices.Device.mini then
    windowLayout = {
      { "Alacritty", nil, primaryScreen, hs.layout.maximized, nil, nil },
      { "Xcode", nil, primaryScreen, hs.layout.maximized, nil, nil },
    }
  elseif devices.current == devices.Device.mbp then
    if secondaryScreen then
      windowLayout = {
        { "Alacritty", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Xcode", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Simulator", nil, primaryScreen, hs.layout.right25, nil, nil },
        { apps.browserAppName, nil, primaryScreen, hs.layout.left75, nil, nil },

        { "Telegram", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
        { "Messages", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
        { "WeChat", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
        { "Discord", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },

        { "Music", nil, primaryScreen, { x = 0.05, y = 0.1, w = 0.55, h = 0.8 }, nil, nil },
      }
    else
      windowLayout = {
        { "Alacritty", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Xcode", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Simulator", nil, primaryScreen, hs.layout.right25, nil, nil },
        { apps.browserAppName, nil, primaryScreen, hs.layout.left75, nil, nil },

        { "Telegram", nil, primaryScreen, { x = 0.15, y = 0.0, w = 0.7, h = 1.0 }, nil, nil },
        { "Messages", nil, primaryScreen, { x = 0.15, y = 0.0, w = 0.7, h = 1.0 }, nil, nil },
        { "WeChat", nil, primaryScreen, { x = 0.15, y = 0.0, w = 0.7, h = 1.0 }, nil, nil },
        { "Discord", nil, primaryScreen, { x = 0.15, y = 0.0, w = 0.7, h = 1.0 }, nil, nil },

        { "Music", nil, primaryScreen, { x = 0.05, y = 0.1, w = 0.55, h = 0.8 }, nil, nil },
      }
    end
  elseif devices.current == devices.Device.work then
    windowLayout = {
      { "Alacritty", nil, primaryScreen, hs.layout.maximized, nil, nil },
      { "Xcode", nil, secondaryScreen, hs.layout.maximized, nil, nil },
      { "Simulator", nil, primaryScreen, hs.layout.right25, nil, nil },
      { apps.browserAppName, nil, primaryScreen, hs.layout.left75, nil, nil },

      { "Telegram", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
      { "Messages", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
      { "WeChat", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },
      { "Discord", nil, primaryScreen, { x = 0.5, y = 0.15, w = 0.45, h = 0.7 }, nil, nil },

      { "Music", nil, primaryScreen, { x = 0.05, y = 0.1, w = 0.55, h = 0.8 }, nil, nil },

      { "Microsoft Outlook", nil, primaryScreen, { x = 0.15, y = 0.05, w = 0.7, h = 0.9 }, nil, nil },
      { "Microsoft Teams", nil, primaryScreen, { x = 0.15, y = 0.05, w = 0.7, h = 0.9 }, nil, nil },
    }
  end

  hs.layout.apply(windowLayout)
end

return layoutApps
