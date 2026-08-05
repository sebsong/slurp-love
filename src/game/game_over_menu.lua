local GameOverMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Collision = require("engine.collision")
local Scene = require("engine.scene")
local Settings = require("engine.settings")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local menu

local gameOverTextTransform

local restartButton
local mainMenuButton

function GameOverMenu.load()
    local menuImage = love.graphics.newImage("assets/art/game_over_menu.png")
    local menuSprite = Sprite.new(menuImage)
    menu = {
        sprite = menuSprite,
        transform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, Align.CENTER, Align.CENTER),
    }

    gameOverTextTransform = love.math.newTransform(0, 50)

    local buttonImage = love.graphics.newImage("assets/art/button.png")
    local numButtonFrames = 2

    local restartSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local restartTransform =
        Align.screenAlignedTransform(restartSprite.width, restartSprite.height, Align.CENTER, Align.CENTER)
    restartButton = Button.new(restartSprite, restartTransform, Font.medium, "restart", nil, function(_button)
        Scene.stop(Scene.scenes.gameOverMenu)
        Scene.restart(Scene.scenes.game)
    end)

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local mainMenuTransform = Align.screenAlignedTransform(
        mainMenuSprite.width,
        mainMenuSprite.height,
        Align.CENTER,
        Align.CENTER,
        0,
        mainMenuSprite.height * 1.1
    )
    mainMenuButton = Button.new(mainMenuSprite, mainMenuTransform, Font.medium, "main menu", nil, function(_button)
        Scene.transition(Scene.scenes.mainMenu)
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
    -- Sprite.draw(menu.sprite, menu.transform)
    love.graphics.setFont(Font.large)
    love.graphics.printf("you're fired", gameOverTextTransform, Settings.canvasPixelWidth, "center")

    restartButton:draw()
    mainMenuButton:draw()

    love.graphics.pop()
end

return GameOverMenu
