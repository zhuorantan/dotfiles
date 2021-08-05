local function sizeFunc(units)
    return function (window, screen)
        window.x = screen.w * units.x + screen.x
        window.y = screen.h * units.y + screen.y
        window.w = screen.w * units.w
        window.h = screen.h * units.h

        return window
    end
end


return {
    fullScreen = sizeFunc({x=0, y=0, w=1, h=1}),
    horizontalCenter = sizeFunc({x=1/4, y=1/8, w=1/2, h=3/4}),
    verticalCenter = sizeFunc({x=1/8, y=1/4, w=3/4, h=1/2}),

    leftHalf = sizeFunc({x=0, y=0, w=1/2, h=1}),
    leftThird = sizeFunc({x=0, y=0, w=1/3, h=1}),
    leftTwoThirds= sizeFunc({x=0, y=0, w=2/3, h=1}),

    bottomHalf = sizeFunc({x=0, y=1/2, w=1, h=1/2}),
    bottomThird = sizeFunc({x=0, y=2/3, w=1, h=1/3}),
    bottomTwoThirds = sizeFunc({x=0, y=1/3, w=1, h=2/3}),

    topHalf = sizeFunc({x=0, y=0, w=1, h=1/2}),
    topThird = sizeFunc({x=0, y=0, w=1, h=1/3}),
    topTwoThirds = sizeFunc({x=0, y=0, w=1, h=2/3}),

    rightHalf = sizeFunc({x=1/2, y=0, w=1/2, h=1}),
    rightThird = sizeFunc({x=2/3, y=0, w=1/3, h=1}),
    rightTwoThirds = sizeFunc({x=1/3, y=0, w=2/3, h=1}),

    centerHorizontalThird = sizeFunc({x=0, y=1/3, w=1, h=1/3}),
    centerVerticalThird = sizeFunc({x=1/3, y=0, w=1/3, h=1}),
}
