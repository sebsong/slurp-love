local Input = require("engine.input")
local SceneManager = require("engine.scene_manager")
local Settings = require("engine.settings")

local DayTracker = require("game.scenes.day_tracker")
local Font = require("game.font")

local DAY_TO_NAME = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
}

local DayTransition = {}

local dayTransitionBackgroundImage

local showContinueText
local blinkTimer
local BLINK_HOLD_TIME = 1

function DayTransition.load()
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
    love.graphics.setFont(Font.large)
    love.graphics.draw(dayTransitionBackgroundImage)
    love.graphics.printf(
        DAY_TO_NAME[DayTracker.currentDay],
        0,
        2 * Font.large:getHeight(),
        Settings.canvasPixelWidth,
        "center"
    )

    if showContinueText then
        love.graphics.setFont(Font.medium)
        love.graphics.printf(
            string.format("press any button to continue", DayTracker.currentDay),
            0,
            Settings.canvasPixelHeight - (4 * Font.medium:getHeight()),
            Settings.canvasPixelWidth,
            "center"
        )
    end
end

return DayTransition
