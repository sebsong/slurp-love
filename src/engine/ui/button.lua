local Align = require("engine.ui.align")
local Collision = require("engine.collision")
local Color = require("engine.color")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

---@class Button
---@field enabled boolean
---@field sprite Sprite
---@field textBox TextBox
---@field transform love.Transform
---@field collider Collider
---@field onHover fun(self: Button)?
---@field onPress fun(self: Button)?
local Button = {}
Button.__index = Button

local DEFAULT_STATE = 1
local HOVERED_STATE = 2
local DISABLED_STATE = 3

---@param image love.Image
---@param transform love.Transform
---@param font love.Font
---@param text string
---@param onHover fun(self: Button)?
---@param onPress fun(self: Button)?
---@return Button
function Button.new(image, transform, font, text, onHover, onPress)
    local sprite = Sprite.newAnimated(image, {
        [DEFAULT_STATE] = {},
        [HOVERED_STATE] = {},
        [DISABLED_STATE] = {},
    })
    local width, height = sprite.width, sprite.height

    local button = {
        enabled = true,

        sprite = sprite,
        textBox = TextBox.new(
            transform,
            width,
            height,
            font,
            Color.palette[8],
            text,
            Align.CENTER,
            Align.CENTER,
            "center"
        ),
        transform = transform,
        collider = { width = width, height = height },

        onHover = onHover,
        onPress = onPress,
    }
    setmetatable(button, Button)

    return button
end

function Button:disable()
    self.enabled = false
    self.sprite:transitionAnimationState(DISABLED_STATE)
end

function Button:enable()
    self.enabled = true
    self.sprite:transitionAnimationState(DEFAULT_STATE)
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function Button:mousepressed(x, y, button, isTouch, presses)
    if not self.enabled then
        return
    end

    if Collision.hitTest(x, y, self.collider, self.transform) then
        if self.onPress then
            self:onPress()
        end
    end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param isTouch boolean
function Button:mousemoved(x, y, dx, dy, isTouch)
    if not self.enabled then
        return
    end

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
