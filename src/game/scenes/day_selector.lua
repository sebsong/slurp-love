local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local DayTracker = require("game.scenes.day_tracker")
local Font = require("game.font")
local GameUi = require("game.ui")

local DaySelector = {}

---@type love.Image
local daySelectorMenuImage
---@type TextBox
local daySelectorTitle
---@type Button
local backButton
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

function DaySelector.load()
    daySelectorMenuImage = love.graphics.newImage("assets/art/day_selector_menu.png")

    daySelectorTitle = TextBox.new(
        love.math.newTransform(0, GameUi.PADDING),
        Settings.canvasPixelWidth,
        Settings.canvasPixelHeight,
        Font.large,
        Color.palette[4],
        "select day",
        Align.CENTER,
        Align.TOP,
        "center"
    )

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local backButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.LEFT,
        Align.TOP,
        GameUi.PADDING,
        GameUi.PADDING
    )
    backButton = Button.new(buttonImage, backButtonTranform, Font.medium, "back", nil, function()
        SceneManager.transition(SceneManager.scenes.mainMenu)
    end)

    local mondayButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.BOTTOM,
        -(GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x),
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    mondayButton = Button.new(buttonImage, mondayButtonTranform, Font.medium, "monday", nil, function()
        DayTracker.selectDay(1)
    end)

    local tuesdayButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.BOTTOM,
        0,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    tuesdayButton = Button.new(buttonImage, tuesdayButtonTranform, Font.medium, "tuesday", nil, function()
        DayTracker.selectDay(2)
    end)

    local wednesdayButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.BOTTOM,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x),
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.y) + GameUi.PADDING
    )
    wednesdayButton = Button.new(buttonImage, wednesdayButtonTranform, Font.medium, "wednesday", nil, function()
        DayTracker.selectDay(3)
    end)

    local thursdayButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.BOTTOM,
        -(GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x) / 2,
        GameUi.PADDING
    )
    thursdayButton = Button.new(buttonImage, thursdayButtonTranform, Font.medium, "thursday", nil, function()
        DayTracker.selectDay(4)
    end)

    local fridayButtonTranform = Align.screenAlignedTransform(
        GameUi.BUTTON_DIMENSIONS.x,
        GameUi.BUTTON_DIMENSIONS.y,
        Align.CENTER,
        Align.BOTTOM,
        (GameUi.PADDING + GameUi.BUTTON_DIMENSIONS.x) / 2,
        GameUi.PADDING
    )
    fridayButton = Button.new(buttonImage, fridayButtonTranform, Font.medium, "friday", nil, function()
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

function DaySelector.unload() end

function DaySelector.onPause() end

function DaySelector.onResume() end

function DaySelector.keypressed(key, scancode, isRepeat) end

function DaySelector.mousepressed(x, y, button, isTouch, presses)
    backButton:mousepressed(x, y, button, isTouch, presses)
    mondayButton:mousepressed(x, y, button, isTouch, presses)
    tuesdayButton:mousepressed(x, y, button, isTouch, presses)
    wednesdayButton:mousepressed(x, y, button, isTouch, presses)
    thursdayButton:mousepressed(x, y, button, isTouch, presses)
    fridayButton:mousepressed(x, y, button, isTouch, presses)
end

function DaySelector.mousemoved(x, y, dx, dy, isTouch)
    backButton:mousemoved(x, y, dx, dy, isTouch)
    mondayButton:mousemoved(x, y, dx, dy, isTouch)
    tuesdayButton:mousemoved(x, y, dx, dy, isTouch)
    wednesdayButton:mousemoved(x, y, dx, dy, isTouch)
    thursdayButton:mousemoved(x, y, dx, dy, isTouch)
    fridayButton:mousemoved(x, y, dx, dy, isTouch)
end

function DaySelector.wheelmoved(x, y) end

function DaySelector.update(dt) end

function DaySelector.draw()
    love.graphics.draw(daySelectorMenuImage)
    daySelectorTitle:draw()
    backButton:draw()
    mondayButton:draw()
    tuesdayButton:draw()
    wednesdayButton:draw()
    thursdayButton:draw()
    fridayButton:draw()
end

return DaySelector
