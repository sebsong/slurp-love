local VictoryMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local Sprite = require("engine.sprite")

local Font = require("game.font")
local GameUi = require("game.ui")

local menu

local victoryTextTransform
local mainMenuButton

function VictoryMenu.load()
    local menuImage = love.graphics.newImage("assets/art/victory_menu.png")
    local menuSprite = Sprite.new(menuImage)
    menu = {
        sprite = menuSprite,
        transform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, "center", "center"),
    }

    victoryTextTransform = love.math.newTransform(0, 50)

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
    -- Sprite.draw(menu.sprite, menu.transform)
    love.graphics.setFont(Font.large)
    love.graphics.printf("you're hired", victoryTextTransform, Settings.canvasPixelWidth, "center")

    mainMenuButton:draw()

    love.graphics.pop()
end

return VictoryMenu
