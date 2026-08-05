local GameOverMenu = {}

local Align = require("engine.ui.align")
local Animation = require("engine.animation")
local Collision = require("engine.collision")
local Scene = require("engine.scene")
local Settings = require("engine.settings")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local menu

local gameOverTextTransform

local restartButton
local mainMenuButton

function GameOverMenu.load()
    local menuImage = love.graphics.newImage("assets/art/game_over_menu.png")
    local menuSprite = Sprite.new(menuImage)
    menu = {
        sprite = menuSprite,
        transform = Align.newAlignedTransform(menuSprite.width, menuSprite.height, Align.CENTER, Align.CENTER),
    }

    gameOverTextTransform = love.math.newTransform(0, 50)

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local numButtonFrames = 2
    local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
    local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

    local restartSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    restartButton = {
        sprite = restartSprite,
        transform = Align.newAlignedTransform(restartSprite.width, restartSprite.height, Align.CENTER, Align.CENTER),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
        isPressed = false,
        isHovered = false,
    }

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    mainMenuButton = {
        sprite = mainMenuSprite,
        transform = Align.newAlignedTransform(
            mainMenuSprite.width,
            mainMenuSprite.height,
            Align.CENTER,
            Align.CENTER,
            0,
            mainMenuSprite.height * 1.1
        ),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
        isPressed = false,
        isHovered = false,
    }
end

function GameOverMenu.unload() end

function GameOverMenu.onPause() end

function GameOverMenu.onResume() end

function GameOverMenu.keypressed(key, scancode, isRepeat) end

function GameOverMenu.mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, restartButton.collider, restartButton.transform) then
        Scene.stop(Scene.scenes.gameOverMenu)
        Scene.restart(Scene.scenes.game)
    end

    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        Scene.transition(Scene.scenes.mainMenu)
    end
end

function GameOverMenu.mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, restartButton.collider, restartButton.transform) then
        restartButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        restartButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end

    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        mainMenuButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        mainMenuButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end
end

function GameOverMenu.wheelmoved(x, y) end

function GameOverMenu.update(dt) end

function GameOverMenu.draw()
    love.graphics.push()

    love.graphics.setShader()
    -- Sprite.draw(menu.sprite, menu.transform)
    love.graphics.setFont(Font.large)
    love.graphics.printf("you're fired", gameOverTextTransform, Settings.canvasPixelWidth, "center")

    love.graphics.setFont(Font.medium)
    Sprite.draw(restartButton.sprite, restartButton.transform)
    love.graphics.print("restart\n day", restartButton.transform:transformPoint(10, 15))
    Sprite.draw(mainMenuButton.sprite, mainMenuButton.transform)
    love.graphics.print("main menu", mainMenuButton.transform:transformPoint(10, 15))

    love.graphics.pop()
end

return GameOverMenu
