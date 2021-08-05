local Sizes = require('window/sizes')
local Moves = require('window/moves')
local Validate = require('window/validate')

local function windowSize(screen, name)
    local size = Sizes[name]

    return {
        x = screen.w * size.x + screen.x,
        y = screen.h * size.y + screen.y,
        w = screen.w * size.w,
        h = screen.h * size.h,
    }
end

local command = {}

for name, definition in pairs(Moves) do
    command[name] = function (window, screen)
        for current, target in pairs(definition.map) do
            if Validate[current](window, screen) then
                return windowSize(screen, target)
            end
        end

        if not definition.default then
            return window
        end

        return windowSize(screen, definition.default)
    end
end

function command.fullScreen(window, screen)
    return windowSize(screen, "fullScreen")
end

function command.moveCenter(window, screen)
    if screen.w > screen.h then
        return windowSize(screen, "horizontalCenter")
    else
        return windowSize(screen, "verticalCenter")
    end
end

function command.movePrevScreen(window, screen)
    local currentWindow = hs.window.focusedWindow()
    local currentScreen = currentWindow:screen()
    local prevScreen = currentScreen:previous()
    local prevScreenFrame = prevScreen:frame()

    if Validate.inScreenBounds(window, prevScreenFrame) then
        return command.moveCenter(window, prevScreenFrame)
    else
        return windowSize(prevScreenFrame, "fullScreen")
    end
end

function command.moveNextScreen(window, screen)
    local currentWindow = hs.window.focusedWindow()
    local currentScreen = currentWindow:screen()
    local nextScreen = currentScreen:next()
    local nextScreenFrame = nextScreen:frame()

    if Validate.inScreenBounds(window, nextScreenFrame) then
        return command.moveCenter(window, nextScreenFrame)
    else
        return windowSize(nextScreenFrame, "fullScreen")
    end
end

return command
