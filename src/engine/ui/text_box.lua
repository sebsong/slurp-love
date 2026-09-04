local Align = require("engine.ui.align")

---@class TextBox
---@field transform love.Transform
---@field text love.Text
---@field width integer
---@field height integer
---@field private boxTransform love.Transform
local TextBox = {}
TextBox.__index = TextBox

--TODO: take in colored text instead of color and text separately
---@param transform love.Transform
---@param width integer
---@param height integer
---@param font love.Font
---@param coloredText table
---@param horizontalAlign HorizontalAlignOption
---@param verticalAlign VerticalAlignOption
---@param textAlignMode love.AlignMode
---@return TextBox
function TextBox.new(transform, width, height, font, coloredText, horizontalAlign, verticalAlign, textAlignMode)
    horizontalAlign = horizontalAlign or "center"
    verticalAlign = verticalAlign or "center"
    textAlignMode = textAlignMode or "center"

    local text = love.graphics.newText(font, coloredText)
    text:setf(coloredText, width, textAlignMode)

    local textTransform =
        Align.alignedTransform(transform, width, height, width, text:getHeight(), horizontalAlign, verticalAlign)

    local textBox = {
        transform = textTransform,
        text = text,
        width = width,
        height = height,

        boxTransform = transform,
    }
    setmetatable(textBox, TextBox)

    return textBox
end

--TODO: this should technically re-align the text transform
---@param coloredText table
function TextBox:setText(coloredText)
    self.text:set(coloredText)
end

function TextBox:draw()
    love.graphics.draw(self.text, self.transform)
end

function TextBox:debugDrawBounds()
    local x, y = self.boxTransform:transformPoint(0, 0)
    love.graphics.rectangle("line", x, y, self.width, self.height)
end

return TextBox
