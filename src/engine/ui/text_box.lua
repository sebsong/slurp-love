local Align = require("engine.ui.align")

---@class TextBox
---@field transform love.Transform
---@field text love.Text
---
---@field new fun(transform: love.Transform, width: integer, height: integer, font: love.Font, color: table, text: string, horizontalAlign: HorizontalAlignOption, verticalAlign: VerticalAlignOption, textAlignMode: love.AlignMode): TextBox
---@field setText fun(self: TextBox, text: string)
---@field draw fun(self: TextBox)
local TextBox = {}
TextBox.__index = TextBox

--TODO: allow color selection
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
    }
    setmetatable(textBox, TextBox)

    return textBox
end

function TextBox:addText(rawText)
    self.text:add(rawText)
end

function TextBox:draw()
    love.graphics.draw(self.text, self.transform)
end

return TextBox
