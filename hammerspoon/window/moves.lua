return {
    moveUp = {
        map = {
            bottomHalf = "topHalf",
            bottomThird = "centerHorizontalThird",
            bottomTwoThirds = "topTwoThirds",
            centerHorizontalThird = "topThird",
        },
        default = "topHalf",
    },
    moveDown = {
        map = {
            topHalf = "bottomHalf",
            topThird = "centerHorizontalThird",
            topTwoThirds = "bottomTwoThirds",
            centerHorizontalThird = "bottomThird",
        },
        default = "bottomHalf",
    },
    moveLeft = {
        map = {
            rightHalf = "leftHalf",
            rightThird = "centerVerticalThird",
            rightTwoThirds = "leftTwoThirds",
            centerVerticalThird = "leftThird",
        },
        default = "leftHalf",
    },
    moveRight = {
        map = {
            leftHalf = "rightHalf",
            leftThird = "centerVerticalThird",
            leftTwoThirds = "rightTwoThirds",
            centerVerticalThird = "rightThird",
        },
        default = "rightHalf",
    },
    resizeUp = {
        map = {
            fullScreen = "topTwoThirds",
            topHalf = "topThird",
            topTwoThirds = "topHalf",
            bottomHalf = "bottomTwoThirds",
            bottomThird = "bottomHalf",
            bottomTwoThirds = "fullScreen",
            centerHorizontalThird = "topTwoThirds",
        },
    },
    resizeDown = {
        map = {
            fullScreen = "bottomTwoThirds",
            topHalf = "topTwoThirds",
            topThird = "topHalf",
            topTwoThirds = "fullScreen",
            bottomHalf = "bottomThird",
            bottomTwoThirds = "bottomHalf",
            centerHorizontalThird = "bottomTwoThirds",
        },
    },
    resizeLeft = {
        map = {
            fullScreen = "leftTwoThirds",
            leftHalf = "leftThird",
            leftTwoThirds = "leftHalf",
            rightHalf = "rightTwoThirds",
            rightThird = "rightHalf",
            rightTwoThirds = "fullScreen",
            centerVerticalThird = "leftTwoThirds",
        },
    },
    resizeRight = {
        map = {
            fullScreen = "rightTwoThirds",
            leftHalf = "leftTwoThirds",
            leftThird = "leftHalf",
            leftTwoThirds = "fullScreen",
            rightHalf = "rightThird",
            rightTwoThirds = "rightHalf",
            centerVerticalThird = "rightTwoThirds",
        },
    },
}
