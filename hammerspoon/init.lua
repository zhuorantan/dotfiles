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
local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/dotfiles/hammerspoon", reloadConfig):start()
hs.alert.show("Config loaded")

-- Application keybinding
local function toggleApp(name)
    return function ()
        local app = hs.application.find(name)

        if app and hs.application.frontmostApplication() == app and next(app:visibleWindows()) ~= nil then
            app:hide()
        else
            hs.application.launchOrFocus(name)
        end
    end
end

hs.hotkey.bind(hyper, "i", toggleApp("Terminal"))
hs.hotkey.bind(hyper, "x", toggleApp("Xcode"))
hs.hotkey.bind(hyper, "r", toggleApp("Simulator"))
hs.hotkey.bind(hyper, "s", toggleApp(browserAppName))
hs.hotkey.bind(hyper, "m", toggleApp("Telegram"))
hs.hotkey.bind(hyper, "u", toggleApp("Messages"))
hs.hotkey.bind(hyper, "w", toggleApp("WeChat"))
hs.hotkey.bind(hyper, "0", toggleApp("Music"))
hs.hotkey.bind(hyper, "o", toggleApp("Microsoft Outlook"))
hs.hotkey.bind(hyper, "e", toggleApp("Microsoft Teams"))

-- Enter ScreenSaver
hs.hotkey.bind(hyper, "8", hs.caffeinate.startScreensaver)

-- Apps navigation
local function newEmacsNaviBind(key, target)
    return hs.hotkey.new({"ctrl"}, key, function()
        hs.eventtap.keyStroke({}, target)
    end)
end

local msftEmacsNaviKeys = {
    newEmacsNaviBind("b", "left"),
    newEmacsNaviBind("f", "right"),
    newEmacsNaviBind("p", "up"),
    newEmacsNaviBind("n", "down")
}

local weChatNaviKeys = {
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

local appWatcher = hs.application.watcher.new(toggleEmacsNaviKeys):start()

-- Window layout
local leftScreen = hs.screen{x=0,y=0}
local rightScreen = hs.screen{x=1,y=0}

local windowLayout = {
    {"Terminal", nil, leftScreen, hs.layout.maximized, nil, nil},
    {"Xcode", nil, rightScreen, hs.layout.maximized, nil, nil},
    {"Simulator", nil, leftScreen, hs.layout.right25, nil, nil},
    {browserAppName, nil, leftScreen, hs.layout.left75, nil, nil},

    {"Telegram", nil, leftScreen, {x=0.5, y=0.15, w=0.45, h=0.7}, nil, nil},
    {"Messages", nil, leftScreen, {x=0.5, y=0.15, w=0.45, h=0.7}, nil, nil},
    {"WeChat", nil, leftScreen, {x=0.5, y=0.15, w=0.45, h=0.7}, nil, nil},

    {"Music", nil, leftScreen, {x=0.05, y=0.1, w=0.55, h=0.8}, nil, nil},

    {"Microsoft Outlook", nil, leftScreen, {x=0.15, y=0.05, w=0.7, h=0.9}, nil, nil},
    {"Microsoft Teams", nil, leftScreen, {x=0.15, y=0.05, w=0.7, h=0.9}, nil, nil},
}

hs.layout.apply(windowLayout)
hs.hotkey.bind(hyper, "'", function()
    hs.layout.apply(windowLayout)
end)

-- Window management
hs.window.animationDuration = 0

local Window = require('window/window')

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

    element:elementSearch(function(_, elementSearchObject, count)
        if count > 0 then
            elementSearchObject[1]:performAction("AXPress")
            return
        end

        -- Try to find an alert stack

        element:elementSearch(function(_, elementSearchObject, count)
            if count > 0 then
                elementSearchObject[1]:performAction("AXPress")
            end

            element:elementSearch(function(_, elementSearchObject, count)
                if count == 0 then
                    hs.alert.show("No notifications")
                    return
                end

                elementSearchObject[1]:performAction("AXPress")
            end, alertSearchFunc)
        end, stackSearchFunc)
    end, alertSearchFunc)
end

hs.hotkey.bind(hyper, ";", clickTopNotification)
