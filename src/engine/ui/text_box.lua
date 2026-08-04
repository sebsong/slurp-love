local Ui = require("engine.ui.ui")

local TextBox = {}
local meta = {}
meta.__index = meta

function TextBox.new(width, transform, font, text, alignMode)
    local textBox = {
        width = width,
        transform = transform,
        font = font,
        text = text,
        alignMode = alignMode,
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
