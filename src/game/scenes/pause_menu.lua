local PauseMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")

local Font = require("game.font")
local GameUi = require("game.ui")

local OPEN_STATE = 1
local CLOSED_STATE = 2

local isOpen
local shouldStop

local menu
local titleTextTransform

local resumeButton
local mainMenuButton

function PauseMenu.open()
    SceneManager.scenes.pauseMenu:start()
end

function PauseMenu.close()
    isOpen = false
    Sprite.transitionAnimationState(menu.sprite, CLOSED_STATE)
end

function PauseMenu.toggle()
    local gameScene = SceneManager.scenes.game
    local pauseScene = SceneManager.scenes.pauseMenu
    if not pauseScene.isActive then
        PauseMenu.open()
        gameScene:pause()
    else
        PauseMenu.close()
        gameScene:resume() -- TODO: need to have some ref counter for how many things pausing the game
    end
end

function PauseMenu.load()
    isOpen = false
    shouldStop = false
    local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
    local menuSprite = Sprite.newAnimated(menuImage, {
        [OPEN_STATE] = {
            numFrames = 6,
            duration = 0.15,
            isLooping = false,
            isReversed = false,
            onFinish = function()
                isOpen = true
            end,
        },
        [CLOSED_STATE] = {
            numFrames = 6,
            duration = 0.15,
            isLooping = false,
            isReversed = false,
            onFinish = function()
                shouldStop = true
            end,
        },
    })
    menu = {
        sprite = menuSprite,
        transform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, Align.CENTER, Align.CENTER),
    }

    titleTextTransform =
        Align.screenAlignedTransform(menuSprite.width, Font.large:getHeight(), Align.CENTER, Align.CENTER, 0, -75)

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local resumeTransform =
        Align.screenAlignedTransform(GameUi.BUTTON_DIMENSIONS.x, GameUi.BUTTON_DIMENSIONS.y, Align.CENTER, Align.CENTER)
    resumeButton = Button.new(buttonImage, resumeTransform, Font.medium, "resume", nil, function(_button)
        PauseMenu.toggle()
    end)

    local mainMenuTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.CENTER,
        0,
        GameUi.BUTTON_DIMENSIONS.y + GameUi.PADDING
    )
    mainMenuButton = Button.new(buttonImage, mainMenuTransform, Font.medium, "main menu", nil, function(_button)
        SceneManager.transition(SceneManager.scenes.mainMenu)
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
    menu.sprite:update(dt)

    if shouldStop then
        SceneManager.scenes.pauseMenu:stop()
    end
end

function PauseMenu.draw()
    love.graphics.push()

    love.graphics.setShader()
    menu.sprite:draw(menu.transform)

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
