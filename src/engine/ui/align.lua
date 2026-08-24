local Settings = require("engine.settings")

---@class Align
local Align = {}

---@alias HorizontalAlignOption "left" | "center" | "right"
---@alias VerticalAlignOption "top" | "center" | "bottom"

---@param originTransform love.Transform
---@param originWidth integer
---@param originHeight integer
---@param width integer
---@param height integer
---@param horizontalAlign HorizontalAlignOption
---@param verticalAlign VerticalAlignOption
---@param xPadding integer?
---@param yPadding integer?
---@return love.Transform
function Align.alignedTransform(
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

    if horizontalAlign == "left" then
    elseif horizontalAlign == "center" then
        x = x + (originWidth / 2) - (width / 2)
    elseif horizontalAlign == "right" then
        x = x + originWidth - width
        xOffset = -xOffset
    else
        error(("invalid align option: %d"):format(horizontalAlign))
    end

    if verticalAlign == "top" then
    elseif verticalAlign == "center" then
        y = y + (originHeight / 2) - (height / 2)
    elseif verticalAlign == "bottom" then
        y = y + originHeight - height
        yOffset = -yOffset
    else
        error(("invalid align option: %d"):format(verticalAlign))
    end

    return love.math.newTransform(x + xOffset, y + yOffset)
end

---@param width integer
---@param height integer
---@param horizontalAlign HorizontalAlignOption
---@param verticalAlign VerticalAlignOption
---@param xPadding integer?
---@param yPadding integer?
---@return love.Transform
function Align.screenAlignedTransform(width, height, horizontalAlign, verticalAlign, xPadding, yPadding)
    return Align.alignedTransform(
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

return Align
