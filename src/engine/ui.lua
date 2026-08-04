local Button = {}
local Ui = {
    align = {
        CENTER = 1,
        LEFT = 2,
        RIGHT = 3,
        TOP = 4,
        BOTTOM = 5,
    },
    Button,
}

local Settings = require("engine/settings")

function Ui.newAlignedTransform(width, height, horizontalAlign, verticalAlign, xPadding, yPadding)
    local x, y
    width, height = width or 0, height or 0
    local xOffset, yOffset = xPadding or 0, yPadding or 0

    if horizontalAlign == Ui.align.LEFT then
        x = 0
    elseif horizontalAlign == Ui.align.CENTER then
        x = Settings.canvasPixelWidth / 2 - width / 2
    elseif horizontalAlign == Ui.align.RIGHT then
        x = Settings.canvasPixelWidth - width
        xOffset = -xOffset
    else
        error(("invalid align option: %d"):format(horizontalAlign))
    end

    if verticalAlign == Ui.align.TOP then
        y = 0
    elseif verticalAlign == Ui.align.CENTER then
        y = Settings.canvasPixelHeight / 2 - height / 2
    elseif verticalAlign == Ui.align.BOTTOM then
        y = Settings.canvasPixelHeight - height
        yOffset = -yOffset
    else
        error(("invalid align option: %d"):format(verticalAlign))
    end

    return love.math.newTransform(x + xOffset, y + yOffset)
end

local function enable(self)
    self.enabled = true
end

local function disable(self)
    self.enabled = false
end

function Button.new(onPress)
    return {
        isPressed = false,
        wasPressedByMouse = false,
        isHovered = false,
        enabled = true,

        onPress,

        enable,
        disable,
    }
end

return Ui
