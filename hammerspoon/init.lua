local hyper = {"cmd", "ctrl"}
local browserAppName = hs.application.get(hs.application.defaultAppForUTI("public.html")):name()

-- Fancy config reload
local function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/dotfiles/hammerspoon", reloadConfig):start()
hs.alert.show("Config loaded")

-- Application keybinding
local function toggleApp(name)
    return function ()
        local app = hs.application.find(name)

        if not app or app:isHidden() then
            hs.application.launchOrFocus(name)
        elseif hs.application.frontmostApplication() ~= app then
            app:activate()
        else
            app:hide()
        end
    end
end

hs.hotkey.bind(hyper, "m", toggleApp("Telegram"))
hs.hotkey.bind(hyper, "w", toggleApp("WeChat"))
hs.hotkey.bind(hyper, "u", toggleApp("Messages"))
hs.hotkey.bind(hyper, "s", toggleApp(browserAppName))
hs.hotkey.bind(hyper, "i", toggleApp("Terminal"))
hs.hotkey.bind(hyper, "o", toggleApp("Microsoft Outlook"))
hs.hotkey.bind(hyper, "e", toggleApp("Microsoft Teams"))
hs.hotkey.bind(hyper, "x", toggleApp("Xcode"))
hs.hotkey.bind(hyper, "r", toggleApp("Simulator"))

-- Enter ScreenSaver
hs.hotkey.bind(hyper, "8", hs.caffeinate.startScreensaver)

-- MSFT apps emacs navigation

local function newEmacsNaviBind(key, target)
    return hs.hotkey.new({"ctrl"}, key, function()
        hs.eventtap.keyStroke({}, target)
    end)
end

msftEmacsNaviKeys = {
    newEmacsNaviBind("b", "left"),
    newEmacsNaviBind("f", "right"),
    newEmacsNaviBind("p", "up"),
    newEmacsNaviBind("n", "down")
}

weChatNaviKeys = {
    hs.hotkey.new({"ctrl", "shift"}, "tab", function()
        hs.eventtap.keyStroke({}, "up")
    end),
    hs.hotkey.new({"ctrl"}, "tab", function()
        hs.eventtap.keyStroke({}, "down")
    end)
}

local function toggleEmacsNaviKeys(name, event, app)
    if event == hs.application.watcher.activated then
        if name:sub(1, #"Microsoft") == "Microsoft" then -- MS apps suck
            for _,v in pairs(msftEmacsNaviKeys) do
                v:enable()
            end
        else
            for _,v in pairs(msftEmacsNaviKeys) do
                v:disable()
            end
        end

        if name == "WeChat" then
            for _,v in pairs(weChatNaviKeys) do
                v:enable()
            end
        else
            for _,v in pairs(weChatNaviKeys) do
                v:disable()
            end
        end
    end
end

local appWatcher = hs.application.watcher.new(toggleEmacsNaviKeys)
appWatcher:start()

-- Window layout
local leftScreen = hs.screen{x=0,y=0}
local rightScreen = hs.screen{x=1,y=0}

local windowLayout = {
    {browserAppName, nil, leftScreen, hs.layout.left75, nil, nil},
    {"Simulator", nil, leftScreen, hs.layout.right25, nil, nil},
    {"Terminal", nil, leftScreen, hs.layout.maximized, nil, nil},
    {"Xcode", nil, rightScreen, hs.layout.maximized, nil, nil}
}

hs.hotkey.bind(hyper, "'", function()
    hs.layout.apply(windowLayout)
end)

-- Window management
hs.window.animationDuration = 0

Window = require('window/window')

hs.hotkey.bind(hyper, "return", Window.fullScreen)
hs.hotkey.bind(hyper, "c", Window.moveCenter)
hs.hotkey.bind(hyper, "h", Window.moveLeft)
hs.hotkey.bind(hyper, "j", Window.moveDown)
hs.hotkey.bind(hyper, "k", Window.moveUp)
hs.hotkey.bind(hyper, "l", Window.moveRight)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "p", Window.movePrevScreen)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "n", Window.moveNextScreen)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "h", Window.resizeLeft)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "j", Window.resizeDown)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "k", Window.resizeUp)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "l", Window.resizeRight)

-- Defeating paste blocking
hs.hotkey.bind(hyper, "v", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Music
hs.hotkey.bind(hyper, "p", hs.itunes.playpause)
hs.hotkey.bind(hyper, "]", hs.itunes.next)
hs.hotkey.bind(hyper, "[", hs.itunes.previous)

-- Click top notification
local function clickTopNotification()
    local element = hs.axuielement.applicationElement(hs.appfinder.appFromName("Notification Center"))
    local stackSearchFunc = hs.axuielement.searchCriteriaFunction({attribute = "AXSubrole", value = "AXNotificationCenterAlertStack"})
    local alertSearchFunc = hs.axuielement.searchCriteriaFunction({attribute = "AXSubrole", value = {"AXNotificationCenterAlert", "AXNotificationCenterBanner"}})

    element:elementSearch(function(msg, elementSearchObject, count)
        if count > 0 then
            elementSearchObject[1]:performAction("AXPress")
        end

        element:elementSearch(function(msg, elementSearchObject, count)
            if count == 0 then
                hs.alert.show("No notifications")
                return
            end

            elementSearchObject[1]:performAction("AXPress")
        end, alertSearchFunc)
    end, stackSearchFunc)
end

hs.hotkey.bind(hyper, ";", clickTopNotification)