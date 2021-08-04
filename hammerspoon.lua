local hyper = {"cmd", "ctrl"}

-- Fancy config reload
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/dotfiles/hammerspoon.lua", hs.reload):start()
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
hs.hotkey.bind(hyper, "s", toggleApp("Safari Technology Preview"))
hs.hotkey.bind(hyper, "i", toggleApp("Terminal"))
hs.hotkey.bind(hyper, "o", toggleApp("Microsoft Outlook"))
hs.hotkey.bind(hyper, "e", toggleApp("Microsoft Teams"))
hs.hotkey.bind(hyper, "x", toggleApp("Xcode"))
hs.hotkey.bind(hyper, "r", toggleApp("Simulator"))

-- Enter ScreenSaver
hs.hotkey.bind(hyper, "b", hs.caffeinate.startScreensaver)

-- MSFT apps emacs navigation

local function newEmacsNaviBind(key, target)
    return hs.hotkey.new({"ctrl"}, key, function()
        hs.eventtap.keyStroke({}, target)
    end)
end

emacsNaviKeys = {
    newEmacsNaviBind("b", "left"),
    newEmacsNaviBind("f", "right"),
    newEmacsNaviBind("p", "up"),
    newEmacsNaviBind("n", "down")
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

-- Window layout
local leftScreen = hs.screen{x=0, y=0}
local rightScreen = hs.screen{x=1, y=0}

local windowLayout = {
    {"Safari Technology Preview", nil, leftScreen, hs.layout.left75, nil, nil},
    {"Simulator", nil, leftScreen, hs.layout.right25, nil, nil},
    {"Terminal", nil, leftScreen, hs.layout.maximized, nil, nil},
    {"Xcode", nil, rightScreen, hs.layout.maximized, nil, nil},
}

hs.hotkey.bind(hyper, "'", function()
    hs.layout.apply(windowLayout)
end)

-- Window management
hs.window.animationDuration = 0

local function sizeFocusedWindow(sizeFunc)
    return function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = sizeFunc(win:frame(), screen:frame())

        win:setFrame(frame)
    end
end

local function fullScreen(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h
    return window
end
local function leftHalfScreen(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w // 2
    window.h = screen.h
    return window
end
local function bottomHalfScreen(window, screen)
    window.x = screen.x
    window.y = (screen.h // 2) + screen.y
    window.w = screen.w
    window.h = screen.h // 2

    return window
end
local function topHalfScreen(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h // 2

    return window
end
local function rightHalfScreen(window, screen)
    window.x = (screen.w // 2) + screen.x
    window.y = screen.y
    window.w = screen.w // 2
    window.h = screen.h
    return window
end

hs.hotkey.bind(hyper, "return", sizeFocusedWindow(fullScreen))
hs.hotkey.bind(hyper, "h", sizeFocusedWindow(leftHalfScreen))
hs.hotkey.bind(hyper, "j", sizeFocusedWindow(bottomHalfScreen))
hs.hotkey.bind(hyper, "k", sizeFocusedWindow(topHalfScreen))
hs.hotkey.bind(hyper, "l", sizeFocusedWindow(rightHalfScreen))

-- Defeating paste blocking
hs.hotkey.bind(hyper, "v", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Music
hs.hotkey.bind(hyper, "p", hs.itunes.playpause)
