local GameOverMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameUi = require("game.ui")

local gameOverTextBox

local restartButton
local mainMenuButton

function GameOverMenu.load()
    local gameOverTextBoxTransform = Align.screenAlignedTransform(
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        "center",
        "top",
        0,
        GameUi.PADDING * 6
    )
    gameOverTextBox = TextBox.new(
        gameOverTextBoxTransform,
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        Font.large,
        { Color.palette[8], "you're fired" },
        "center",
        "top",
        "center"
    )

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local restartTransform =
        Align.screenAlignedTransform(GameUi.BUTTON_DIMENSIONS.x, GameUi.BUTTON_DIMENSIONS.y, "center", "center")
    restartButton = Button.new(buttonImage, restartTransform, Font.medium, "restart", nil, function(_button)
        SceneManager.scenes.gameOverMenu:stop()
        SceneManager.scenes.game:restart()
    end)

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

function GameOverMenu.unload() end

function GameOverMenu.onPause() end

function GameOverMenu.onResume() end

function GameOverMenu.keypressed(key, scancode, isRepeat) end

function GameOverMenu.mousepressed(x, y, button, isTouch, presses)
    restartButton:mousepressed(x, y, button, isTouch, presses)
    mainMenuButton:mousepressed(x, y, button, isTouch, presses)
end

function GameOverMenu.mousemoved(x, y, dx, dy, isTouch)
    restartButton:mousemoved(x, y, dx, dy, isTouch)
    mainMenuButton:mousemoved(x, y, dx, dy, isTouch)
end

function GameOverMenu.wheelmoved(x, y) end

function GameOverMenu.update(dt) end

function GameOverMenu.draw()
    love.graphics.push()

    love.graphics.setShader()

    gameOverTextBox:draw()

    restartButton:draw()
    mainMenuButton:draw()

    love.graphics.pop()
end

return GameOverMenu
