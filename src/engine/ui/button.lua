local Align = require("engine.ui.align")
local Collision = require("engine.collision")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

local Button = {}
local meta = {}
meta.__index = meta

local DEFAULT_BUTTON_STATE = 1
local HOVERED_BUTTON_STATE = 2

function Button.new(sprite, transform, font, text, onHover, onPress)
    local width, height = sprite.width, sprite.height

    local button = {
        enabled = true,

        sprite = sprite,
        textBox = TextBox.new(transform, width, height, font, text, Align.CENTER, Align.CENTER, "center"),
        transform = transform,
        collider = { width = width, height = height },

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
        self.sprite.animation.currentFrame = HOVERED_BUTTON_STATE
        if self.onHover then
            self:onHover()
        end
    else
        self.sprite.animation.currentFrame = DEFAULT_BUTTON_STATE
    end
end

function meta:draw()
    Sprite.draw(self.sprite, self.transform)
    self.textBox:draw()
end

return Button
