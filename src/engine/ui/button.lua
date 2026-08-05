local Align = require("engine.ui.align")
local Collision = require("engine.collision")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

local Button = {}
local meta = {}
meta.__index = meta

function Button.new(image, numFrames, font, text, horizontalAlign, verticalAlign, xPadding, yPadding, onHover, onPress)
    local imageWidth, imageHeight = image:getDimensions()
    local colliderWidth, colliderHeight = imageWidth / numFrames, imageHeight
    local sprite = Sprite.newAnimated(image, numFrames)
    local width, height = sprite.width, sprite.height
    local transform = Align.newAlignedTransform(width, height, horizontalAlign, verticalAlign, xPadding, yPadding)

    local button = {
        enabled = true,

        sprite = sprite,
        textBox = TextBox.new(transform, width, height, font, text, Align.CENTER, Align.CENTER, "center"),
        transform = transform,
        collider = { width = colliderWidth, height = colliderHeight },

        onHover = onHover,
        onPress = onPress,
    }
    setmetatable(button, meta)

    return button
end

function meta:mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, self.collider, self.transform) then
        if self.onPress then
            self:onPress()
        end
    end
end

function meta:mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, self.collider, self.transform) then
        if self.onHover then
            self:onHover()
        end
    end
end

function meta:draw()
    Sprite.draw(self.sprite, self.transform)
    self.textBox:draw()
end

return Button
