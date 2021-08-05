local resize = {}
local Sizes = require("window/sizes")

for name, size in pairs(Sizes) do
    resize[name] = function (window, screen)
        window.x = screen.w * size.x + screen.x
        window.y = screen.h * size.y + screen.y
        window.w = screen.w * size.w
        window.h = screen.h * size.h

        return window
    end
end

return resize
