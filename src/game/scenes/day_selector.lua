local Align = require("engine.ui.align")
local Color = require("engine.color")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local DayTracker = require("game.scenes.day_tracker")
local Font = require("game.font")
local GameButton = require("game.button")
local GameUi = require("game.ui")

---@class DaySelector: Scene
---@field baseScene Menu
local DaySelector = Scene.new()

---@type TextBox
local titleTextBox
---@type Button
local mondayButton
---@type Button
local tuesdayButton
---@type Button
local wednesdayButton
---@type Button
local thursdayButton
---@type Button
local fridayButton

function DaySelector:load()
    local menuFrame = self.baseScene.frame
    local frameTransform = menuFrame.transform
    local frameWidth, frameHeight = menuFrame.sprite.width, menuFrame.sprite.height
    local titleTransform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        frameWidth,
        frameHeight,
        "center",
        "center",
        0,
        GameUi.PADDING * 4
    )
    titleTextBox = TextBox.new(
        titleTransform,
        frameWidth,
        frameHeight,
        Font.large,
        { Color.palette[8], "select day" },
        "center",
        "top",
        "center"
    )

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local mondayButtonTranform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "bottom",
        -(GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x),
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    mondayButton = GameButton.new(buttonImage, mondayButtonTranform, Font.medium, "monday", nil, function()
        DayTracker.selectDay(1)
    end)

    local tuesdayButtonTranform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "bottom",
        0,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    tuesdayButton = GameButton.new(buttonImage, tuesdayButtonTranform, Font.medium, "tuesday", nil, function()
        DayTracker.selectDay(2)
    end)

    local wednesdayButtonTranform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "bottom",
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x),
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    wednesdayButton = GameButton.new(buttonImage, wednesdayButtonTranform, Font.medium, "wednesday", nil, function()
        DayTracker.selectDay(3)
    end)

    local thursdayButtonTranform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "bottom",
        -(GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x) / 2,
        GameUi.PADDING
    )
    thursdayButton = GameButton.new(buttonImage, thursdayButtonTranform, Font.medium, "thursday", nil, function()
        DayTracker.selectDay(4)
    end)

    local fridayButtonTranform = Align.alignedTransform(
        frameTransform,
        frameWidth,
        frameHeight,
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        "center",
        "bottom",
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x) / 2,
        GameUi.PADDING
    )
    fridayButton = GameButton.new(buttonImage, fridayButtonTranform, Font.medium, "friday", nil, function()
        DayTracker.selectDay(5)
    end)

    local maxDay = DayTracker.maxDay
    if maxDay < 2 then
        tuesdayButton:disable()
    end
    if maxDay < 3 then
        wednesdayButton:disable()
    end
    if maxDay < 4 then
        thursdayButton:disable()
    end
    if maxDay < 5 then
        fridayButton:disable()
    end
end

function DaySelector:mousepressed(x, y, button, isTouch, presses)
    mondayButton:mousepressed(x, y, button, isTouch, presses)
    tuesdayButton:mousepressed(x, y, button, isTouch, presses)
    wednesdayButton:mousepressed(x, y, button, isTouch, presses)
    thursdayButton:mousepressed(x, y, button, isTouch, presses)
    fridayButton:mousepressed(x, y, button, isTouch, presses)
end

function DaySelector:mousemoved(x, y, dx, dy, isTouch)
    mondayButton:mousemoved(x, y, dx, dy, isTouch)
    tuesdayButton:mousemoved(x, y, dx, dy, isTouch)
    wednesdayButton:mousemoved(x, y, dx, dy, isTouch)
    thursdayButton:mousemoved(x, y, dx, dy, isTouch)
    fridayButton:mousemoved(x, y, dx, dy, isTouch)
end

function DaySelector:draw()
    titleTextBox:draw()
    mondayButton:draw()
    tuesdayButton:draw()
    wednesdayButton:draw()
    thursdayButton:draw()
    fridayButton:draw()
end

return DaySelector
