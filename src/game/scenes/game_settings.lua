local Align = require("engine.ui.align")
local Color = require("engine.color")
local Scene = require("engine.scene")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameUi = require("game.ui")

---@type TextBox
local titleTextBox

--- @class GameSettings : Scene
--- @field baseScene Menu
local GameSettings = Scene.new()

function GameSettings:load()
    local menuFrame = self.baseScene.frame
    local frameWidth, frameHeight = menuFrame.sprite.width, menuFrame.sprite.height
    local titleTransform = Align.alignedTransform(
        menuFrame.transform,
        frameWidth,
        frameHeight,
        frameWidth,
        frameHeight,
        "center",
        "center",
        0,
        GameUi.PADDING * 2
    )
    titleTextBox = TextBox.new(
        titleTransform,
        frameWidth,
        frameHeight,
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
