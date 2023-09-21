local hs = hs

-- Fancy config reload
local function reloadConfig(files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end

  if doReload then
    hs.reload()
  end
end

ConfigWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/dotfiles/hammerspoon", reloadConfig):start()
hs.alert.show("Config loaded")

local numberOfScreens = #hs.screen.allScreens()

ScreenWatcher = hs.screen.watcher.new(function()
  if #hs.screen.allScreens() == numberOfScreens then
    return
  end
  numberOfScreens = #hs.screen.allScreens()
  hs.reload()
end):start()
