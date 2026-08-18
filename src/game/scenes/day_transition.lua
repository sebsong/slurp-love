local Align = require("engine.ui.align")
local Input = require("engine.input")
local Save = require("engine.save")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")
local TextBox = require("engine.ui.text_box")

local DayTracker = require("game.scenes.day_tracker")
local Font = require("game.font")
local GameUi = require("game.ui")

local DAY_TO_NAME = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
}

local DayTransition = {}

local dayTransitionBackgroundImage

local dayTextBox
local continueTextBox

local dayStatsTextBox

local showContinueText
local blinkTimer
local BLINK_HOLD_TIME = 1

local function secondsToTimeString(seconds)
    if not seconds then
        return "no record"
    end

    local minutes = seconds / 60
    local remainderSeconds = seconds % 60
    return ("%d:%.2f"):format(minutes, remainderSeconds)
end

function DayTransition.load()
    local dayTextBoxTransform = Align.screenAlignedTransform(
        Settings.canvasPixelWidth,
        Font.large:getHeight(),
        Align.CENTER,
        Align.TOP,
        0,
        GameUi.PADDING * 2
    )
    dayTextBox = TextBox.new(
        dayTextBoxTransform,
        Settings.canvasPixelWidth,
        Font.large:getHeight(),
        Font.large,
        DAY_TO_NAME[DayTracker.currentDay],
        Align.CENTER,
        Align.CENTER,
        "center"
    )

    local saveData = Save.load()
    local currentDayStats = saveData.dayStats[DayTracker.currentDay]
    local gasRemaining = currentDayStats.gasRemaining
    local elapsedSeconds = currentDayStats.elapsedSeconds

    local dayStatsTextBoxTransform = Align.screenAlignedTransform(
        Settings.canvasPixelWidth,
        Font.medium:getHeight(),
        Align.CENTER,
        Align.CENTER,
        0,
        -GameUi.PADDING * 3
    )
    dayStatsTextBox = TextBox.new(
        dayStatsTextBoxTransform,
        Settings.canvasPixelWidth,
        Font.medium:getHeight(),
        Font.medium,
        ("record:\ngas: %.2f\ntime: %s"):format(gasRemaining, secondsToTimeString(elapsedSeconds)),
        Align.CENTER,
        Align.CENTER,
        "center"
    )

    local continueTextBoxTransform = Align.screenAlignedTransform(
        Settings.canvasPixelWidth,
        Font.medium:getHeight(),
        Align.CENTER,
        Align.BOTTOM,
        0,
        GameUi.PADDING * 4
    )
    continueTextBox = TextBox.new(
        continueTextBoxTransform,
        Settings.canvasPixelWidth,
        Font.medium:getHeight(),
        Font.medium,
        "press any button to continue",
        Align.CENTER,
        Align.CENTER,
        "center"
    )

    dayTransitionBackgroundImage = love.graphics.newImage("assets/art/day_transition_background.png")
    blinkTimer = 0
    showContinueText = true
end

function DayTransition.unload() end

function DayTransition.onPause() end

function DayTransition.onResume() end

function DayTransition.keypressed(key, scancode, isRepeat)
    if Input.MODIFIER_KEYS:contains(key) then
        return
    end

    SceneManager.transition(SceneManager.scenes.game)
end

function DayTransition.mousepressed(x, y, button, isTouch, presses) end

function DayTransition.mousemoved(x, y, dx, dy, isTouch) end

function DayTransition.wheelmoved(x, y) end

function DayTransition.update(dt)
    blinkTimer = blinkTimer + dt
    if blinkTimer > BLINK_HOLD_TIME then
        blinkTimer = 0
        showContinueText = not showContinueText
    end
end

function DayTransition.draw()
    love.graphics.draw(dayTransitionBackgroundImage)
    dayTextBox:draw()

    dayStatsTextBox:draw()

    if showContinueText then
        continueTextBox:draw()
    end
end

return DayTransition
