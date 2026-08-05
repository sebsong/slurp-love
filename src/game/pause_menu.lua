local PauseMenu = {}

local Align = require("engine.ui.align")
local Animation = require("engine.animation")
local Button = require("engine.ui.button")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local isOpen
local shouldStop

local menu
local titleTextTransform

local resumeButton
local mainMenuButton

function PauseMenu.open()
    Scene.start(Scene.scenes.pauseMenu)
end

function PauseMenu.close()
    isOpen = false
    Animation.play(Sprite.getCurrentAnimation(menu.sprite), true, function()
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
    local menuSprite = Sprite.newAnimated(menuImage, 6, 0.15)
    Animation.play(Sprite.getCurrentAnimation(menuSprite), false, function()
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

    local resumeSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local resumeTransform =
        Align.screenAlignedTransform(resumeSprite.width, resumeSprite.height, Align.CENTER, Align.CENTER)
    resumeButton = Button.new(resumeSprite, resumeTransform, Font.medium, "resume", nil, function(_button)
        PauseMenu.toggle()
    end)

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local yOffset = mainMenuSprite.height * 1.1
    local mainMenuTransform = Align.screenAlignedTransform(
        mainMenuSprite.width,
        mainMenuSprite.height,
        Align.CENTER,
        Align.CENTER,
        0,
        yOffset
    )
    mainMenuButton = Button.new(mainMenuSprite, mainMenuTransform, Font.medium, "main menu", nil, function(_button)
        Scene.transition(Scene.scenes.mainMenu)
    end)
end

function PauseMenu.unload() end

function PauseMenu.onPause() end

function PauseMenu.onResume() end

function PauseMenu.keypressed(key, scancode, isRepeat) end

function PauseMenu.mousepressed(x, y, button, isTouch, presses)
    resumeButton:mousepressed(x, y, button, isTouch, presses)
    mainMenuButton:mousepressed(x, y, button, isTouch, presses)
end

function PauseMenu.mousemoved(x, y, dx, dy, isTouch)
    resumeButton:mousemoved(x, y, dx, dy, isTouch)
    mainMenuButton:mousemoved(x, y, dx, dy, isTouch)
end

function PauseMenu.wheelmoved(x, y) end

function PauseMenu.update(dt)
    Sprite.update(menu.sprite, dt)

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

    resumeButton:draw()
    mainMenuButton:draw()

    love.graphics.pop()
end

return PauseMenu
