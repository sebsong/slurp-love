local Align = require("engine.ui.align")
local Color = require("engine.color")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

---@class Menu: Scene
local Menu = Scene.new()
Menu.__index = Menu

---@type love.Image
local menuImage

---@type Button
local closeButton

---@return Menu
function Menu.new()
    local menu = {}
    setmetatable(menu, Menu)
    return menu
end

function Menu:load()
    menuImage = love.graphics.newImage("assets/art/menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local backButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "left",
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
    love.graphics.draw(menuImage)
    closeButton:draw()
end

return Menu
