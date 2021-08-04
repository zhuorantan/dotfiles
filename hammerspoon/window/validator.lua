local validator = {}

local function approxEqual(a, b)
    return math.abs(a - b) < 8
end

function validator.fullScreen(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h)
end

function validator.topHalf(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 2)
end

function validator.topThird(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 3)
end

function validator.topTwoThirds(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 3 * 2)
end

function validator.bottomHalf(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.h // 2 + screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 2)
end

function validator.bottomThird(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.h // 3 * 2 + screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 3)
end

function validator.bottomTwoThirds(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.h // 3 + screen.y) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 3 * 2)
end

function validator.leftHalf(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 2) and
            approxEqual(window.h, screen.h)
end

function validator.leftThird(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 3) and
            approxEqual(window.h, screen.h)
end

function validator.leftTwoThirds(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 3 * 2) and
            approxEqual(window.h, screen.h)
end

function validator.rightHalf(window, screen)
    return approxEqual(window.x, screen.w // 2 + screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 2) and
            approxEqual(window.h, screen.h)
end

function validator.rightThird(window, screen)
    return approxEqual(window.x, screen.w // 3 * 2 + screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 3) and
            approxEqual(window.h, screen.h)
end

function validator.rightTwoThirds(window, screen)
    return approxEqual(window.x, screen.w // 3 + screen.x) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 3 * 2) and
            approxEqual(window.h, screen.h)
end

function validator.centerHorizontalThird(window, screen)
    return approxEqual(window.x, screen.x) and
            approxEqual(window.y, screen.h // 3) and
            approxEqual(window.w, screen.w) and
            approxEqual(window.h, screen.h // 3)
end

function validator.centerVerticalThird(window, screen)
    return approxEqual(window.x, screen.w // 3) and
            approxEqual(window.y, screen.y) and
            approxEqual(window.w, screen.w // 3) and
            approxEqual(window.h, screen.h)
end

return validator
