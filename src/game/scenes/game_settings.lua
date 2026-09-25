local Align = require("engine.ui.align")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local DayTracker = require("game.scenes.day_tracker")
local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

local GameSettings = {}

---@type love.Image
local menuImage
---@type TextBox
local daySelectorTitle

---@type Button
local backButton

function GameSettings.load()
    menuImage = love.graphics.newImage("assets/art/menu.png")

    daySelectorTitle = TextBox.new(
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
    backButton = GameButton.new(buttonImage, backButtonTranform, Font.medium, "back", nil, function()
        SceneManager.transition(SceneManager.scenes.mainMenu)
    end)
end

function GameSettings.unload() end

function GameSettings.onPause() end

function GameSettings.onResume() end

function GameSettings.keypressed(key, scancode, isRepeat) end

function GameSettings.mousepressed(x, y, button, isTouch, presses)
    backButton:mousepressed(x, y, button, isTouch, presses)
end

function GameSettings.mousemoved(x, y, dx, dy, isTouch)
    backButton:mousemoved(x, y, dx, dy, isTouch)
end

function GameSettings.wheelmoved(x, y) end

function GameSettings.update(dt) end

function GameSettings.draw()
    love.graphics.draw(menuImage)
    daySelectorTitle:draw()
    backButton:draw()
end

return GameSettings
