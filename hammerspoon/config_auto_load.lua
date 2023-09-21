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

hs.caffeinate.set("displayIdle", require('utils.is_at_office')(), false)

ScreenWatcher = hs.screen.watcher.new(function()
  hs.reload()
end):start()
