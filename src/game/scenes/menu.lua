local Align = require("engine.ui.align")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

---@class Menu: Scene
---@field subMenu Scene
local Menu = {}
Menu.__index = Menu

---@type love.Image
local menuImage
---@type TextBox
local title

---@type Button
local closeButton

function Menu.new(subMenu)
    local menu = {
        subMenu = subMenu,
    }
    setmetatable(menu, Menu)
    return menu
end

function Menu:load()
    menuImage = love.graphics.newImage("assets/art/menu.png")

    title = TextBox.new(
        love.math.newTransform(0, GameUi.PADDING),
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        Font.large,
        { Color.palette[8], "settings" },
        "center",
        "top",
        "center"
    )

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

    self.subMenu:load()
end

function Menu:keypressed(key, scancode, isRepeat)
    if key == "escape" then
        SceneManager.closeOverlay(self)
    end
end

function Menu:mousepressed(x, y, button, isTouch, presses)
    closeButton:mousepressed(x, y, button, isTouch, presses)
    self.subMenu:mousepressed(x, y, button, isTouch, presses)
end

function Menu:mousemoved(x, y, dx, dy, isTouch)
    closeButton:mousemoved(x, y, dx, dy, isTouch)
end

function Menu:draw()
    love.graphics.draw(menuImage)
    title:draw()
    closeButton:draw()
end

return Menu
