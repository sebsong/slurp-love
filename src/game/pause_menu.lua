local PauseMenu = {}

local Align = require("engine.ui.align")
local Animation = require("engine.animation")
local Collision = require("engine.collision")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local isOpen
local shouldStop

local menu

local resumeButton
local mainMenuButton

local titleTextTransform
local resumeTextTransform
local mainMenuTextTransform

function PauseMenu.open()
    Scene.start(Scene.scenes.pauseMenu)
end

function PauseMenu.close()
    isOpen = false
    Animation.play(menu.sprite.animation, true, function()
        shouldStop = true
    end)
end

function PauseMenu.toggle()
    local gameScene = Scene.scenes.game
    local pauseScene = Scene.scenes.pauseMenu
    if not pauseScene.isActive then
        PauseMenu.open()
        Scene.pause(gameScene)
    else
        PauseMenu.close()
        Scene.resume(gameScene) -- TODO: need to have some ref counter for how many things pausing the game
    end
end

function PauseMenu.load()
    isOpen = false
    shouldStop = false
    local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
    -- local menuSprite = Sprite.new(menuImage)
    local menuSprite = Sprite.newAnimated(menuImage, 6, 0.15)
    Animation.play(menuSprite.animation, false, function()
        isOpen = true
    end)
    menu = {
        sprite = menuSprite,
        transform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, Align.CENTER, Align.CENTER),
    }

    titleTextTransform =
        Align.screenAlignedTransform(menuSprite.width, Font.large:getHeight(), Align.CENTER, Align.CENTER, 0, -75)

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local numButtonFrames = 2
    local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
    local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

    local resumeSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    resumeButton = {
        sprite = resumeSprite,
        transform = Align.screenAlignedTransform(resumeSprite.width, resumeSprite.height, Align.CENTER, Align.CENTER),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
        isPressed = false,
        isHovered = false,
    }
    resumeTextTransform =
        Align.screenAlignedTransform(resumeSprite.width, Font.medium:getHeight(), Align.CENTER, Align.CENTER)

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local yOffset = mainMenuSprite.height * 1.1
    mainMenuButton = {
        sprite = mainMenuSprite,
        transform = Align.screenAlignedTransform(
            mainMenuSprite.width,
            mainMenuSprite.height,
            Align.CENTER,
            Align.CENTER,
            0,
            yOffset
        ),
        collider = { width = buttonColliderWidth, height = buttonColliderHeight },
        isPressed = false,
        isHovered = false,
    }
    mainMenuTextTransform = Align.screenAlignedTransform(
        mainMenuSprite.width,
        Font.medium:getHeight(),
        Align.CENTER,
        Align.CENTER,
        0,
        yOffset
    )
end

function PauseMenu.unload() end

function PauseMenu.onPause() end

function PauseMenu.onResume() end

function PauseMenu.keypressed(key, scancode, isRepeat) end

function PauseMenu.mousepressed(x, y, button, isTouch, presses)
    if Collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
        PauseMenu.toggle()
    end

    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        Scene.transition(Scene.scenes.mainMenu)
    end
end

function PauseMenu.mousemoved(x, y, dx, dy, isTouch)
    if Collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
        resumeButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        resumeButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end

    if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
        mainMenuButton.sprite.animation.currentFrame = HOVER_FRAME
    else
        mainMenuButton.sprite.animation.currentFrame = DEFAULT_FRAME
    end
end

function PauseMenu.wheelmoved(x, y) end

function PauseMenu.update(dt)
    Animation.update(menu.sprite.animation, dt)

    if shouldStop then
        Scene.stop(Scene.scenes.pauseMenu)
    end
end

function PauseMenu.draw()
    love.graphics.push()

    love.graphics.setShader()
    Sprite.draw(menu.sprite, menu.transform)

    if not isOpen then
        love.graphics.pop()
        return
    end

    love.graphics.setFont(Font.large)
    love.graphics.printf("paused", titleTextTransform, menu.sprite.width, "center")

    love.graphics.setFont(Font.medium)
    Sprite.draw(resumeButton.sprite, resumeButton.transform)
    love.graphics.printf("resume", resumeTextTransform, resumeButton.sprite.width, "center")
    Sprite.draw(mainMenuButton.sprite, mainMenuButton.transform)
    love.graphics.printf("main menu", mainMenuTextTransform, mainMenuButton.sprite.width, "center")

    love.graphics.pop()
end

return PauseMenu
