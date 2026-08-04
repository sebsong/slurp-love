local VictoryMenu = {}

local Collision = require("engine/collision")
local Scene = require("engine/scene")
local Settings = require("engine/settings")
local Sprite = require("engine/sprite")
local Ui = require("engine/ui")

local Font = require("game/font")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local menu

local victoryTextTransform
local mainMenuButton

function VictoryMenu.load()
    local menuImage = love.graphics.newImage("assets/art/victory_menu.png")
    local menuSprite = Sprite.new(menuImage)
    menu = {
        sprite = menuSprite,
        transform = Ui.newAlignedTransform(menuSprite.width, menuSprite.height, Ui.align.CENTER, Ui.align.CENTER),
    }

    victoryTextTransform = love.math.newTransform(0, 50)

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local numButtonFrames = 2
    local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
    local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    mainMenuButton = {
        sprite = mainMenuSprite,
        transform = Ui.newAlignedTransform(
            mainMenuSprite.width,
            mainMenuSprite.height,
            Ui.align.CENTER,
            Ui.align.CENTER,
            0,
            mainMenuSprite.height * 1.1
        ),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
        isPressed = false,
        isHovered = false,
    }
end

function VictoryMenu.unload() end

function VictoryMenu.onPause() end

function VictoryMenu.onResume() end

function VictoryMenu.keypressed(key, scancode, isRepeat) end

function VictoryMenu.mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        Scene.transition(Scene.scenes.mainMenu)
    end
end

function VictoryMenu.mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        mainMenuButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        mainMenuButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end
end

function VictoryMenu.wheelmoved(x, y) end

function VictoryMenu.update(dt) end

function VictoryMenu.draw()
    love.graphics.push()

    love.graphics.setShader()
    -- Sprite.draw(menu.sprite, menu.transform)
    love.graphics.setFont(Font.large)
    love.graphics.printf("you're hired", victoryTextTransform, Settings.canvasPixelWidth, "center")

    love.graphics.setFont(Font.medium)
    Sprite.draw(mainMenuButton.sprite, mainMenuButton.transform)
    love.graphics.print("main menu", mainMenuButton.transform:transformPoint(10, 15))

    love.graphics.pop()
end

return VictoryMenu
