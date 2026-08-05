local MainMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Collision = require("engine.collision")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local backgroundImage
local testButton
local playButton
local exitButton

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

function MainMenu.load()
    backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local numButtonFrames = 2
    local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
    local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

    testButton = Button.new(
        buttonImage,
        numButtonFrames,
        Font.large,
        "test",
        Align.RIGHT,
        Align.CENTER,
        50,
        30,
        function(button)
            button.sprite.animation.currentFrame = HOVER_FRAME
        end,
        function(button)
            Scene.transition(Scene.scenes.dayTracker)
        end
    )

    playButton = {
        sprite = Sprite.newAnimated(buttonImage, numButtonFrames),
        transform = love.math.newTransform(75, 175),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
    }

    exitButton = {
        sprite = Sprite.newAnimated(buttonImage, numButtonFrames),
        transform = love.math.newTransform(75, 250),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
    }
end

function MainMenu.unload() end

function MainMenu.onPause() end

function MainMenu.onResume() end

function MainMenu.keypressed(key, scancode, isRepeat) end

function MainMenu.mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, playButton.collider, playButton.transform) then
        Scene.transition(Scene.scenes.dayTracker)
    end

    if Collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
        love.event.quit()
    end

    testButton:mousepressed(x, y, button, isTouch, presses)
end

function MainMenu.mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, playButton.collider, playButton.transform) then
        playButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        playButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end

    if Collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
        exitButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        exitButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end

    testButton:mousemoved(x, y, dx, dy, isTouch)
end

function MainMenu.wheelmoved(x, y) end

function MainMenu.update(dt) end

function MainMenu.draw()
    love.graphics.setFont(Font.large)

    love.graphics.draw(backgroundImage)

    testButton:draw()

    Sprite.draw(playButton.sprite, playButton.transform)
    love.graphics.print("play", playButton.transform:transformPoint(10, 15))
    Sprite.draw(exitButton.sprite, exitButton.transform)
    love.graphics.print("exit", exitButton.transform:transformPoint(10, 15))
    love.graphics.print("abcdefghijklm\nnopqrstuvwxyz", 220, 360 - 64 - 16)
end

return MainMenu
