local Command = require('window/command')

local function sizeFocusedWindow(sizeFunc)
    return function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = sizeFunc(win:frame(), screen:frame())

        win:setFrame(frame)
    end
end

local window = {}

for name, command in pairs(Command) do
    window[name] = sizeFocusedWindow(command)
end

return window
