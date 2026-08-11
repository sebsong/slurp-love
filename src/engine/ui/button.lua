local Align = require("engine.ui.align")
local Collision = require("engine.collision")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

---@class Button
---@field enabled boolean
---@field sprite table
---@field textBox table
---@field transform love.Transform
---@field collider table
---@field onHover fun(self: Button)?
---@field onPress fun(self: Button)?
---
---@field mousepressed fun(self: Button, x: number, y: number, button: number, isTouch: boolean, presses: number)
---@field mousemoved fun(self: Button, x: number, y: number, dx: number, dy: number, isTouch: boolean)
---@field draw fun(self: Button)
local Button = {}
Button.__index = Button

local DEFAULT_STATE = 1
local HOVERED_STATE = 2

function Button.new(image, transform, font, text, onHover, onPress)
    local sprite = Sprite.newAnimated(image, {
        [DEFAULT_STATE] = {},
        [HOVERED_STATE] = {},
    })
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
    setmetatable(button, Button)

    return button
end

function Button:mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, self.collider, self.transform) then
        if self.onPress then
            self:onPress()
        end
    end
end

function Button:mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, self.collider, self.transform) then
        self.sprite:transitionAnimationState(HOVERED_STATE)
        if self.onHover then
            self:onHover()
        end
    else
        self.sprite:transitionAnimationState(DEFAULT_STATE)
    end
end

function Button:draw()
    self.sprite:draw(self.transform)
    self.textBox:draw()
end

return Button
