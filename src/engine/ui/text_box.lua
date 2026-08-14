local Align = require("engine.ui.align")

---@class TextBox
---@field width integer
---@field transform love.Transform
---@field font love.Font
---@field text string
---@field alignMode love.AlignMode
---
---@field new fun(transform: love.Transform, width: integer, height: integer, font: love.Font, text: string, horizontalAlign: HorizontalAlignOption, verticalAlign: VerticalAlignOption, textAlignMode: love.AlignMode): TextBox
---@field setText fun(self: TextBox, text: string)
---@field draw fun(self: TextBox)
local TextBox = {}
TextBox.__index = TextBox

--TODO: use love.Text here
function TextBox.new(transform, width, height, font, rawText, horizontalAlign, verticalAlign, textAlignMode)
    horizontalAlign = horizontalAlign or Align.CENTER
    verticalAlign = verticalAlign or Align.CENTER
    textAlignMode = textAlignMode or "center"

    -- local text = love.graphics.newText(font, rawText)

    local textTransform =
        Align.alignedTransform(transform, width, height, width, font:getHeight(), horizontalAlign, verticalAlign)
    -- Align.alignedTransform(transform, width, height, width, text:getHeight(), horizontalAlign, verticalAlign)

    local textBox = {
        width = width,
        transform = textTransform,
        font = font,
        text = rawText,
        alignMode = textAlignMode,
    }
    setmetatable(textBox, TextBox)

    return textBox
end

function TextBox:setText(rawText)
    -- self.text:set(rawText)
    self.text = rawText
end

function TextBox:draw()
    love.graphics.setFont(self.font)
    love.graphics.printf(self.text, self.transform, self.width, self.alignMode)
end

return TextBox
