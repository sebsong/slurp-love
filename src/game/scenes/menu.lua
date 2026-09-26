local Align = require("engine.ui.align")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")

local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

---@class Menu: Scene
---@field frame table
local Menu = Scene.new()
Menu.__index = Menu

---@type Button
local closeButton

---@return Menu
function Menu.new()
    local menu = {
        frame = {},
    }
    setmetatable(menu, Menu)
    return menu
end

function Menu:load()
    local menuImage = love.graphics.newImage("assets/art/menu.png")
    local menuSprite = Sprite.new(menuImage)
    local menuTransform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, "center", "center")
    self.frame = {
        sprite = menuSprite,
        transform = menuTransform,
    }

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local backButtonTranform = Align.alignedTransform(
        menuTransform,
        menuSprite.width,
        menuSprite.height,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "right",
        "top",
        GameUi.PADDING,
        GameUi.PADDING
    )
    closeButton = GameButton.new(buttonImage, backButtonTranform, Font.medium, "close", nil, function()
        SceneManager.closeOverlay(self)
    end)
end

function Menu:keypressed(key, scancode, isRepeat)
    if key == "escape" then
        SceneManager.closeOverlay(self)
    end
end

function Menu:mousepressed(x, y, button, isTouch, presses)
    closeButton:mousepressed(x, y, button, isTouch, presses)
end

function Menu:mousemoved(x, y, dx, dy, isTouch)
    closeButton:mousemoved(x, y, dx, dy, isTouch)
end

function Menu:draw()
    self.frame.sprite:draw(self.frame.transform)
    closeButton:draw()
end

return Menu
