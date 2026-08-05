local Align = require("engine.ui.align")

local TextBox = {}
local meta = {}
meta.__index = meta

function TextBox.new(transform, width, height, font, text, horizontalAlign, verticalAlign, textAlignMode)
    horizontalAlign = horizontalAlign or Align.CENTER
    verticalAlign = verticalAlign or Align.CENTER
    textAlignMode = textAlignMode or "center"

    local textTransform =
        Align._newAlignedTransform(transform, width, height, width, font:getHeight(), horizontalAlign, verticalAlign)

    local textBox = {
        width = width,
        transform = textTransform,
        font = font,
        text = text,
        alignMode = textAlignMode,
    }
    setmetatable(textBox, meta)

    return textBox
end

function meta:setText(text)
    self.text = text
end

function meta:draw()
    love.graphics.setFont(self.font)
    love.graphics.printf(self.text, self.transform, self.width, self.alignMode)
end

return TextBox
