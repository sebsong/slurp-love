local VictoryMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameUi = require("game.ui")

local victoryTextBox
local mainMenuButton

function VictoryMenu.load()
    local victoryTextBoxTransform = Align.screenAlignedTransform(
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        "center",
        "top",
        0,
        GameUi.PADDING * 6
    )
    victoryTextBox = TextBox.new(
        victoryTextBoxTransform,
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        Font.large,
        { Color.palette[8], "you're hired" },
        "center",
        "top",
        "center"
    )

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local mainMenuTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "center",
        0,
        GameUi.BUTTON_DIMENSIONS.y + GameUi.PADDING
    )
    mainMenuButton = Button.new(buttonImage, mainMenuTransform, Font.medium, "main menu", nil, function(_button)
        SceneManager.transition(SceneManager.scenes.mainMenu)
    end)
end

function VictoryMenu.unload() end

function VictoryMenu.onPause() end

function VictoryMenu.onResume() end

function VictoryMenu.keypressed(key, scancode, isRepeat) end

function VictoryMenu.mousepressed(x, y, button, isTouch, presses)
    mainMenuButton:mousepressed(x, y, button, isTouch, presses)
end

function VictoryMenu.mousemoved(x, y, dx, dy, isTouch)
    mainMenuButton:mousemoved(x, y, dx, dy, isTouch)
end

function VictoryMenu.wheelmoved(x, y) end

function VictoryMenu.update(dt) end

function VictoryMenu.draw()
    love.graphics.push()

    love.graphics.setShader()

    victoryTextBox:draw()

    mainMenuButton:draw()

    love.graphics.pop()
end

return VictoryMenu
