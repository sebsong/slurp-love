local Align = require("engine.ui.align")

---@class TextBox
---@field transform love.Transform
---@field text love.Text
---@field width integer
---@field height integer
---@field private boxTransform love.Transform
local TextBox = {}
TextBox.__index = TextBox

---@param transform love.Transform
---@param width integer
---@param height integer
---@param font love.Font
---@param color table
---@param rawText string
---@param horizontalAlign HorizontalAlignOption
---@param verticalAlign VerticalAlignOption
---@param textAlignMode love.AlignMode
---@return TextBox
function TextBox.new(transform, width, height, font, color, rawText, horizontalAlign, verticalAlign, textAlignMode)
    horizontalAlign = horizontalAlign or Align.CENTER
    verticalAlign = verticalAlign or Align.CENTER
    textAlignMode = textAlignMode or "center"

    local text = love.graphics.newText(font, rawText)
    text:setf({ color, rawText }, width, textAlignMode)

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
--TODO: convert all method annotations to use this style
---@overload fun(self: TextBox, coloredtext: table)
---@param rawText string
function TextBox:setText(rawText)
    self.text:set(rawText)
end

function TextBox:draw()
    love.graphics.draw(self.text, self.transform)
end

function TextBox:debugDrawBounds()
    local x, y = self.boxTransform:transformPoint(0, 0)
    love.graphics.rectangle("line", x, y, self.width, self.height)
end

return TextBox
