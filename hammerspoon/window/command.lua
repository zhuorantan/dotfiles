local Resize = require('window/resize')
local Validate = require('window/validate')

local command = {}

local moveDefinitions = {
    moveUp = {
        map = {
            bottomHalf = "topHalf",
            bottomThird = "centerHorizontalThird",
            bottomTwoThirds = "topTwoThirds",
            centerHorizontalThird = "topThird",
        },
        default = "topHalf",
    },
    moveDown = {
        map = {
            topHalf = "bottomHalf",
            topThird = "centerHorizontalThird",
            topTwoThirds = "bottomTwoThirds",
            centerHorizontalThird = "bottomThird",
        },
        default = "bottomHalf",
    },
    moveLeft = {
        map = {
            rightHalf = "leftHalf",
            rightThird = "centerVerticalThird",
            rightTwoThirds = "leftTwoThirds",
            centerVerticalThird = "leftThird",
        },
        default = "leftHalf",
    },
    moveRight = {
        map = {
            leftHalf = "rightHalf",
            leftThird = "centerVerticalThird",
            leftTwoThirds = "rightTwoThirds",
            centerVerticalThird = "rightThird",
        },
        default = "rightHalf",
    },
    resizeUp = {
        map = {
            fullScreen = "topTwoThirds",
            topHalf = "topThird",
            topTwoThirds = "topHalf",
            bottomHalf = "bottomTwoThirds",
            bottomThird = "bottomHalf",
        }
    }
}

for name, definition in pairs(moveDefinitions) do
    command[name] = function (window, screen)
        for current, target in pairs(definition.map) do
            if Validate[current](window, screen) then
                return Resize[target](window, screen)
            end
        end

        return Resize[definition.default](window, screen)
    end
end

function command.moveCenter(window, screen)
    if screen.w > screen.h then
        return Resize.horizontalCenter(window, screen)
    else
        return Resize.verticalCenter(window, screen)
    end
end

function command.resizeUp(window, screen)
    if Validate.fullScreen(window, screen) then
        return Resize.topTwoThirds(window, screen)
    elseif Validate.topHalf(window, screen) then
        return Resize.topThird(window, screen)
    elseif Validate.topTwoThirds(window, screen) then
        return Resize.topHalf(window, screen)
    elseif Validate.bottomHalf(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validate.bottomThird(window, screen) then
        return Resize.bottomHalf(window, screen)
    elseif Validate.bottomTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validate.centerHorizontalThird(window, screen) then
        return Resize.topTwoThirds(window, screen)
    end

    return window
end

function command.resizeDown(window, screen)
    if Validate.fullScreen(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validate.topHalf(window, screen) then
        return Resize.topTwoThirds(window, screen)
    elseif Validate.topThird(window, screen) then
        return Resize.topHalf(window, screen)
    elseif Validate.topTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validate.bottomHalf(window, screen) then
        return Resize.bottomThird(window, screen)
    elseif Validate.bottomTwoThirds(window, screen) then
        return Resize.bottomHalf(window, screen)
    elseif Validate.centerHorizontalThird(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    end

    return window
end

function command.resizeLeft(window, screen)
    if Validate.fullScreen(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validate.leftHalf(window, screen) then
        return Resize.leftThird(window, screen)
    elseif Validate.leftTwoThirds(window, screen) then
        return Resize.leftHalf(window, screen)
    elseif Validate.rightHalf(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validate.rightThird(window, screen) then
        return Resize.rightHalf(window, screen)
    elseif Validate.rightTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validate.centerVerticalThird(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    end

    return window
end

function command.resizeRight(window, screen)
    if Validate.fullScreen(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validate.leftHalf(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validate.leftThird(window, screen) then
        return Resize.leftHalf(window, screen)
    elseif Validate.leftTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validate.rightHalf(window, screen) then
        return Resize.rightThird(window, screen)
    elseif Validate.rightTwoThirds(window, screen) then
        return Resize.rightHalf(window, screen)
    elseif Validate.centerVerticalThird(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    end

    return window
end

function command.movePrevScreen(window, screen)
    local currentWindow = hs.window.focusedWindow()
    local currentScreen = currentWindow:screen()
    local prevScreen = currentScreen:previous()
    local prevScreenFrame = prevScreen:frame()

    if Validate.inScreenBounds(window, prevScreenFrame) then
        return command.moveCenter(window, prevScreenFrame)
    else
        return Resize.fullScreen(window, prevScreenFrame)
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
        return Resize.fullScreen(window, nextScreenFrame)
    end
end

return command
