local Align = require("engine.ui.align")
local SceneManager = require("engine.scene_manager")

local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

local MainMenu = {}

---@type love.Image
local backgroundImage

---@type Button
local playButton
---@type Button
local daySelectorButton
---@type Button
local gameSettingsButton
---@type Button
local exitButton

function MainMenu.load()
    backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local playButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "right",
        "bottom",
        GameUi.PADDING,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) * 3 + GameUi.PADDING
    )
    playButton = GameButton.new(buttonImage, playButtonTransform, Font.medium, "play", nil, function()
        SceneManager.transition(SceneManager.scenes.dayTransition)
    end)

    local daySelectorButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "right",
        "bottom",
        GameUi.PADDING,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) * 2 + GameUi.PADDING
    )
    daySelectorButton = GameButton.new(
        buttonImage,
        daySelectorButtonTransform,
        Font.medium,
        "select day",
        nil,
        function()
            SceneManager.transition(SceneManager.scenes.daySelector)
        end
    )

    local gameSettingsButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "right",
        "bottom",
        GameUi.PADDING,
        GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y + GameUi.PADDING
    )
    gameSettingsButton = GameButton.new(
        buttonImage,
        gameSettingsButtonTransform,
        Font.medium,
        "settings",
        nil,
        function()
            SceneManager.transition(SceneManager.scenes.gameSettings)
        end
    )

    local exitButtonTransform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "right",
        "bottom",
        GameUi.PADDING,
        GameUi.PADDING
    )
    exitButton = GameButton.new(buttonImage, exitButtonTransform, Font.medium, "exit", nil, function()
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
    gameSettingsButton:mousepressed(x, y, button, isTouch, presses)
    exitButton:mousepressed(x, y, button, isTouch, presses)
end

function MainMenu.mousemoved(x, y, dx, dy, isTouch)
    playButton:mousemoved(x, y, dx, dy, isTouch)
    daySelectorButton:mousemoved(x, y, dx, dy, isTouch)
    gameSettingsButton:mousemoved(x, y, dx, dy, isTouch)
    exitButton:mousemoved(x, y, dx, dy, isTouch)
end

function MainMenu.wheelmoved(x, y) end

function MainMenu.update(dt) end

function MainMenu.draw()
    love.graphics.draw(backgroundImage)
    playButton:draw()
    daySelectorButton:draw()
    gameSettingsButton:draw()
    exitButton:draw()
end

return MainMenu
