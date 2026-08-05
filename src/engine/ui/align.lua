local Settings = require("engine.settings")

local Align = {
    CENTER = 1,
    LEFT = 2,
    RIGHT = 3,
    TOP = 4,
    BOTTOM = 5,
}

function Align.newAlignedTransform(width, height, horizontalAlign, verticalAlign, xPadding, yPadding)
    return Align._newAlignedTransform(
        love.math.newTransform(0, 0),
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        width,
        height,
        horizontalAlign,
        verticalAlign,
        xPadding,
        yPadding
    )
end

function Align._newAlignedTransform(
    originTransform,
    originWidth,
    originHeight,
    width,
    height,
    horizontalAlign,
    verticalAlign,
    xPadding,
    yPadding
)
    local x, y = originTransform:transformPoint(0, 0)
    width, height = width or 0, height or 0
    local xOffset, yOffset = xPadding or 0, yPadding or 0

    if horizontalAlign == Align.LEFT then
    elseif horizontalAlign == Align.CENTER then
        x = x + (originWidth / 2) - (width / 2)
    elseif horizontalAlign == Align.RIGHT then
        x = x + originWidth - width
        xOffset = -xOffset
    else
        error(("invalid align option: %d"):format(horizontalAlign))
    end

    if verticalAlign == Align.TOP then
    elseif verticalAlign == Align.CENTER then
        y = y + (originHeight / 2) - (height / 2)
    elseif verticalAlign == Align.BOTTOM then
        y = y + originHeight - height
        yOffset = -yOffset
    else
        error(("invalid align option: %d"):format(verticalAlign))
    end

    return love.math.newTransform(x + xOffset, y + yOffset)
end

return Align
