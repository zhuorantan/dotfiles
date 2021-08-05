local validate = {}
local Sizes = require("window/sizes")

local function approxEqual(a, b)
    return math.abs(a - b) < 8
end

local function windowSize(screen, size)
    local window = {}
    window.x = screen.w * size.x + screen.x
    window.y = screen.h * size.y + screen.y
    window.w = screen.w * size.w
    window.h = screen.h * size.h

    return window
end

for name, size in pairs(Sizes) do
    validate[name] = function (window, screen)
        local newWindow = windowSize(screen, Sizes[name])

        return approxEqual(window.x, newWindow.x) and
                approxEqual(window.y, newWindow.y) and
                approxEqual(window.w, newWindow.w) and
                approxEqual(window.h, newWindow.h)
    end
end

function validate.inScreenBounds(window, screen)
    return window.w <= screen.w and
            window.h <= screen.h
end

return validate
