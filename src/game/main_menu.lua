local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Collision = require("engine.collision")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local MainMenu = {}

local PADDING = 20

local backgroundImage

---@type Button
local playButton
local exitButton

function MainMenu.load()
    backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")
    local numButtonFrames = 2

    local playButtonSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local playButtonTransform = Align.screenAlignedTransform(
        playButtonSprite.width,
        playButtonSprite.height,
        Align.LEFT,
        Align.BOTTOM,
        PADDING,
        PADDING + playButtonSprite.height + PADDING
    )
    playButton = Button.new(playButtonSprite, playButtonTransform, Font.large, "play", nil, function()
        Scene.transition(Scene.scenes.dayTracker)
    end)

    local exitButtonSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local exitButtonTransform = Align.screenAlignedTransform(
        exitButtonSprite.width,
        exitButtonSprite.height,
        Align.LEFT,
        Align.BOTTOM,
        PADDING,
        PADDING
    )
    exitButton = Button.new(exitButtonSprite, exitButtonTransform, Font.large, "exit", nil, function()
        love.event.quit()
    end)
end

function MainMenu.unload() end

function MainMenu.onPause() end

function MainMenu.onResume() end

function MainMenu.keypressed(key, scancode, isRepeat) end

function MainMenu.mousepressed(x, y, button, isTouch, presses)
    playButton:mousepressed(x, y, button, isTouch, presses)
    exitButton:mousepressed(x, y, button, isTouch, presses)
end

function MainMenu.mousemoved(x, y, dx, dy, isTouch)
    playButton:mousemoved(x, y, dx, dy, isTouch)
    exitButton:mousemoved(x, y, dx, dy, isTouch)
end

function MainMenu.wheelmoved(x, y) end

function MainMenu.update(dt) end

function MainMenu.draw()
    love.graphics.draw(backgroundImage)
    playButton:draw()
    exitButton:draw()
end

return MainMenu
