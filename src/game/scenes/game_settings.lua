local Align = require("engine.ui.align")
local Color = require("engine.color")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

---@type TextBox
local titleTextBox

--- @class GameSettings : Scene
--- @field baseScene Menu
local GameSettings = Scene.new()

function GameSettings:load()
    titleTextBox = TextBox.new(
        love.math.newTransform(0, GameUi.PADDING),
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        Font.large,
        { Color.palette[8], "settings" },
        "center",
        "top",
        "center"
    )
end

function GameSettings:mousepressed(x, y, button, isTouch, presses) end

function GameSettings:mousemoved(x, y, dx, dy, isTouch) end

function GameSettings:draw()
    titleTextBox:draw()
end

return GameSettings
