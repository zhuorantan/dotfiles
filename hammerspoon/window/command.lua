Resize = require('window/resize')
Validator = require('window/validator')

local command = {}

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

return command
