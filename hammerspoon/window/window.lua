Resize = require('window/resize')
Command = require('window/command')

local function sizeFocusedWindow(sizeFunc)
    return function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = sizeFunc(win:frame(), screen:frame())

        win:setFrame(frame)
    end
end

return {
    fullScreen = sizeFocusedWindow(Resize.fullScreen),
    moveCenter = sizeFocusedWindow(Command.moveCenter),
    moveUp = sizeFocusedWindow(Command.moveUp),
    moveDown = sizeFocusedWindow(Command.moveDown),
    moveLeft = sizeFocusedWindow(Command.moveLeft),
    moveRight = sizeFocusedWindow(Command.moveRight),
    resizeUp = sizeFocusedWindow(Command.resizeUp),
    resizeDown = sizeFocusedWindow(Command.resizeDown),
    resizeLeft = sizeFocusedWindow(Command.resizeLeft),
    resizeRight = sizeFocusedWindow(Command.resizeRight),
    movePrevScreen = sizeFocusedWindow(Command.movePrevScreen),
    moveNextScreen = sizeFocusedWindow(Command.moveNextScreen)
}
