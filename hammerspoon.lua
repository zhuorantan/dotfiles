-- Fancy config reload
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/dotfiles/hammerspoon.lua", hs.reload):start()
hs.alert.show("Config loaded")

-- Application keybinding
local function open(name)
    return function()
        hs.application.launchOrFocus(name)
    end
end

hs.hotkey.bind({"cmd", "ctrl"}, "m", open("Telegram"))
hs.hotkey.bind({"cmd", "ctrl"}, "s", open("Safari Technology Preview"))
hs.hotkey.bind({"cmd", "ctrl"}, "i", open("Terminal"))
hs.hotkey.bind({"cmd", "ctrl"}, "o", open("Microsoft Outlook"))
hs.hotkey.bind({"cmd", "ctrl"}, "e", open("Microsoft Teams"))
hs.hotkey.bind({"cmd", "ctrl"}, "x", open("Xcode"))

-- MSFT apps emacs navigation

local function newEmacsNaviBind(key, target)
    return hs.hotkey.new({"ctrl"}, key, function()
        hs.eventtap.keyStroke({}, target)
    end)
end

emacsNaviKeys = {
    newEmacsNaviBind("b", "left"),
    newEmacsNaviBind("f", "right")
}

local function toggleEmacsNaviKeys(name, event, app)
    if event == hs.application.watcher.activated then
        if name:sub(1, #"Microsoft") == "Microsoft" then -- MS apps suck
            for k,v in pairs(emacsNaviKeys) do
                v:enable()
            end
        else
            for k,v in pairs(emacsNaviKeys) do
                v:disable()
            end
        end
    end
end

hs.application.watcher.new(toggleEmacsNaviKeys):start()

-- Defeating paste blocking
hs.hotkey.bind({"cmd", "ctrl"}, "v", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Music
hs.hotkey.bind({"cmd", "ctrl"}, "p", hs.itunes.playpause)
