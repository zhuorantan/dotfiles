local validate = {}
local Sizes = require("window/sizes")

local function approxEqual(a, b)
    return math.abs(a - b) < 8
end

local function windowSize(screen, name)
    local size = Sizes[name]

    return {
        x = screen.w * size.x + screen.x,
        y = screen.h * size.y + screen.y,
        w = screen.w * size.w,
        h = screen.h * size.h,
    }
end

for name, size in pairs(Sizes) do
    validate[name] = function (window, screen)
        local newWindow = windowSize(screen, name)

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
