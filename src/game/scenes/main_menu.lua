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
local daySelectorButton
---@type Button
local exitButton

function MainMenu.load()
    backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local playButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "left",
        "bottom",
        GameUi.PADDING,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) * 2 + GameUi.PADDING
    )
    playButton = Button.new(buttonImage, playButtonTransform, Font.medium, "play", nil, function()
        SceneManager.transition(SceneManager.scenes.dayTransition)
    end)

    local daySelectorButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "left",
        "bottom",
        GameUi.PADDING,
        GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y + GameUi.PADDING
    )
    daySelectorButton = Button.new(buttonImage, daySelectorButtonTransform, Font.medium, "select day", nil, function()
        SceneManager.transition(SceneManager.scenes.daySelector)
    end)

    local exitButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "left",
        "bottom",
        GameUi.PADDING,
        GameUi.PADDING
    )
    exitButton = Button.new(buttonImage, exitButtonTransform, Font.medium, "exit", nil, function()
        love.event.quit()
    end)
end

function MainMenu.unload() end

function MainMenu.onPause() end

function MainMenu.onResume() end

function MainMenu.keypressed(key, scancode, isRepeat) end

function MainMenu.mousepressed(x, y, button, isTouch, presses)
    playButton:mousepressed(x, y, button, isTouch, presses)
    daySelectorButton:mousepressed(x, y, button, isTouch, presses)
    exitButton:mousepressed(x, y, button, isTouch, presses)
end

function MainMenu.mousemoved(x, y, dx, dy, isTouch)
    playButton:mousemoved(x, y, dx, dy, isTouch)
    daySelectorButton:mousemoved(x, y, dx, dy, isTouch)
    exitButton:mousemoved(x, y, dx, dy, isTouch)
end

function MainMenu.wheelmoved(x, y) end

function MainMenu.update(dt) end

function MainMenu.draw()
    love.graphics.draw(backgroundImage)
    playButton:draw()
    daySelectorButton:draw()
    exitButton:draw()
end

return MainMenu
