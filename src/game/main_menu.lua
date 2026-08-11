local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local SceneManager = require("engine.scene_manager")

local Font = require("game.font")
local GameUi = require("game.ui")

local MainMenu = {}

---@type love.Image
local backgroundImage

---@type Button
local playButton
---@type Button
local exitButton

function MainMenu.load()
    backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local playButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.LEFT,
        Align.BOTTOM,
        GameUi.PADDING,
        GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y + GameUi.PADDING
    )
    playButton = Button.new(buttonImage, playButtonTransform, Font.large, "play", nil, function()
        SceneManager.transition(SceneManager.scenes.dayTracker)
    end)

    local exitButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.LEFT,
        Align.BOTTOM,
        GameUi.PADDING,
        GameUi.PADDING
    )
    exitButton = Button.new(buttonImage, exitButtonTransform, Font.large, "exit", nil, function()
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
