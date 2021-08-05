local resize = {}

function resize.fullScreen(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h
    return window
end

function resize.horizontalCenter(window, screen)
    window.x = screen.w // 4 + screen.x
    window.y = screen.h // 8 + screen.y
    window.w = screen.w // 2
    window.h = screen.h * 3 // 4
    return window
end

function resize.verticalCenter(window, screen)
    window.x = screen.w // 8 + screen.x
    window.y = screen.h // 4 + screen.y
    window.w = screen.w * 3 // 4
    window.h = screen.h // 2
    return window
end

function resize.leftHalf(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w // 2
    window.h = screen.h
    return window
end

function resize.leftThird(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w // 3
    window.h = screen.h
    return window
end

function resize.leftTwoThirds(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w // 3 * 2
    window.h = screen.h
    return window
end

function resize.bottomHalf(window, screen)
    window.x = screen.x
    window.y = screen.h // 2 + screen.y
    window.w = screen.w
    window.h = screen.h // 2
    return window
end

function resize.bottomThird(window, screen)
    window.x = screen.x
    window.y = screen.h // 3 * 2 + screen.y
    window.w = screen.w
    window.h = screen.h // 3
    return window
end

function resize.bottomTwoThirds(window, screen)
    window.x = screen.x
    window.y = screen.h // 3 + screen.y
    window.w = screen.w
    window.h = screen.h // 3 * 2
    return window
end

function resize.topHalf(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h // 2

    return window
end

function resize.topThird(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h // 3
    return window
end

function resize.topTwoThirds(window, screen)
    window.x = screen.x
    window.y = screen.y
    window.w = screen.w
    window.h = screen.h // 3 * 2
    return window
end

function resize.rightHalf(window, screen)
    window.x = screen.w // 2 + screen.x
    window.y = screen.y
    window.w = screen.w // 2
    window.h = screen.h
    return window
end

function resize.rightThird(window, screen)
    window.x = screen.w // 3 * 2 + screen.x
    window.y = screen.y
    window.w = screen.w // 3
    window.h = screen.h
    return window
end

function resize.rightTwoThirds(window, screen)
    window.x = screen.w // 3 + screen.x
    window.y = screen.y
    window.w = screen.w // 3 * 2
    window.h = screen.h
    return window
end

function resize.centerHorizontalThird(window, screen)
    window.x = screen.x
    window.y = screen.h // 3
    window.w = screen.w
    window.h = screen.h // 3
    return window
end

function resize.centerVerticalThird(window, screen)
    window.x = screen.w // 3
    window.y = screen.y
    window.w = screen.w // 3
    window.h = screen.h
    return window
end

return resize
