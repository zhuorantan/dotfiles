Resize = require('window/resize')
Validator = require('window/validator')

local command = {}

function command.moveCenter(window, screen)
    if screen.w > screen.h then
        return Resize.horizontalCenter(window, screen)
    else
        return Resize.verticalCenter(window, screen)
    end
end

function command.moveUp(window, screen)
    if Validator.bottomHalf(window, screen) then
        return Resize.topHalf(window, screen)
    elseif Validator.bottomThird(window, screen) then
        return Resize.centerHorizontalThird(window, screen)
    elseif Validator.bottomTwoThirds(window, screen) then
        return Resize.topTwoThirds(window, screen)
    elseif Validator.centerHorizontalThird(window, screen) then
        return Resize.topThird(window, screen)
    end

    return Resize.topHalf(window, screen)
end

function command.moveDown(window, screen)
    if Validator.topHalf(window, screen) then
        return Resize.bottomHalf(window, screen)
    elseif Validator.topThird(window, screen) then
        return Resize.centerHorizontalThird(window, screen)
    elseif Validator.topTwoThirds(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validator.centerHorizontalThird(window, screen) then
        return Resize.bottomThird(window, screen)
    end

    return Resize.bottomHalf(window, screen)
end

function command.moveLeft(window, screen)
    if Validator.rightHalf(window, screen) then
        return Resize.leftHalf(window, screen)
    elseif Validator.rightThird(window, screen) then
        return Resize.centerVerticalThird(window, screen)
    elseif Validator.rightTwoThirds(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validator.centerVerticalThird(window, screen) then
        return Resize.leftThird(window, screen)
    end

    return Resize.leftHalf(window, screen)
end

function command.moveRight(window, screen)
    if Validator.leftHalf(window, screen) then
        return Resize.rightHalf(window, screen)
    elseif Validator.leftThird(window, screen) then
        return Resize.centerVerticalThird(window, screen)
    elseif Validator.leftTwoThirds(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validator.centerVerticalThird(window, screen) then
        return Resize.rightThird(window, screen)
    end

    return Resize.rightHalf(window, screen)
end

function command.resizeUp(window, screen)
    if Validator.fullScreen(window, screen) then
        return Resize.topTwoThirds(window, screen)
    elseif Validator.topHalf(window, screen) then
        return Resize.topThird(window, screen)
    elseif Validator.topTwoThirds(window, screen) then
        return Resize.topThird(window, screen)
    elseif Validator.bottomHalf(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validator.bottomThird(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validator.bottomTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validator.centerHorizontalThird(window, screen) then
        return Resize.topTwoThirds(window, screen)
    end

    return window
end

function command.resizeDown(window, screen)
    if Validator.fullScreen(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    elseif Validator.topHalf(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validator.topThird(window, screen) then
        return Resize.topTwoThirds(window, screen)
    elseif Validator.topTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validator.bottomHalf(window, screen) then
        return Resize.bottomThird(window, screen)
    elseif Validator.bottomTwoThirds(window, screen) then
        return Resize.bottomThird(window, screen)
    elseif Validator.centerHorizontalThird(window, screen) then
        return Resize.bottomTwoThirds(window, screen)
    end

    return window
end

function command.resizeLeft(window, screen)
    if Validator.fullScreen(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validator.leftHalf(window, screen) then
        return Resize.leftThird(window, screen)
    elseif Validator.leftTwoThirds(window, screen) then
        return Resize.leftThird(window, screen)
    elseif Validator.rightHalf(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validator.rightThird(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validator.rightTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validator.centerVerticalThird(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    end

    return window
end

function command.resizeRight(window, screen)
    if Validator.fullScreen(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    elseif Validator.leftHalf(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validator.leftThird(window, screen) then
        return Resize.leftTwoThirds(window, screen)
    elseif Validator.leftTwoThirds(window, screen) then
        return Resize.fullScreen(window, screen)
    elseif Validator.rightHalf(window, screen) then
        return Resize.rightThird(window, screen)
    elseif Validator.rightTwoThirds(window, screen) then
        return Resize.rightThird(window, screen)
    elseif Validator.centerVerticalThird(window, screen) then
        return Resize.rightTwoThirds(window, screen)
    end

    return window
end

function command.movePrevScreen(window, screen)
    local currentWindow = hs.window.focusedWindow()
    local currentScreen = currentWindow:screen()
    local prevScreen = currentScreen:previous()
    local prevScreenFrame = prevScreen:frame()

    if Validator.inScreenBounds(window, prevScreenFrame) then
        return Resize.center(window, prevScreenFrame)
    else
        return Resize.fullScreen(window, prevScreenFrame)
    end
end

function command.moveNextScreen(window, screen)
    local currentWindow = hs.window.focusedWindow()
    local currentScreen = currentWindow:screen()
    local nextScreen = currentScreen:next()
    local nextScreenFrame = nextScreen:frame()

    if Validator.inScreenBounds(window, nextScreenFrame) then
        return Resize.center(window, nextScreenFrame)
    else
        return Resize.fullScreen(window, nextScreenFrame)
    end
end

return command
