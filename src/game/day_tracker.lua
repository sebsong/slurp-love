local FIRST_DAY = 1
local FINAL_DAY = 5
local DAY_TO_NAME = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
}

local DayTracker = {
    currentDay = FIRST_DAY,
}

local Input = require("engine.input")
local Save = require("engine.save")
local Scene = require("engine.scene")
local Settings = require("engine.settings")

local Font = require("game.font")

local dayTransitionBackgroundImage

local showContinueText
local blinkTimer
local BLINK_HOLD_TIME = 1

local function startDay()
    Scene.transition(Scene.scenes.game)
end

function DayTracker.nextDay(gasRemaining)
    if DayTracker.currentDay == FINAL_DAY then
        if not Scene.scenes.victoryMenu.isActive then
            Scene.start(Scene.scenes.victoryMenu)
        end
        return
    end

    DayTracker.currentDay = DayTracker.currentDay + 1

    Save.update(function(saveData)
        local currentDay = DayTracker.currentDay
        saveData.currentDay = currentDay

        if currentDay > saveData.maxDay then
            saveData.maxDay = currentDay
        end

        -- TODO: track time taken
        local currentDayStats = saveData.dayStats[currentDay]
        if gasRemaining > currentDayStats.gasRemaining then
            currentDayStats.gasRemaining = gasRemaining
        end
    end)

    Scene.transition(Scene.scenes.dayTracker)
end

local function initializeSaveData()
    Save.update(function(saveData)
        if not saveData.currentDay then
            saveData.currentDay = FIRST_DAY
        end

        if not saveData.maxDay then
            saveData.maxDay = FIRST_DAY
        end

        if not saveData.dayStats then
            saveData.dayStats = {}
        end

        for i = FIRST_DAY, FINAL_DAY do
            if not saveData.dayStats[i] then
                saveData.dayStats[i] = {}
            end

            if not saveData.dayStats[i].gasRemaining then
                saveData.dayStats[i].gasRemaining = -1
            end
        end
    end)
end

function DayTracker.load()
    dayTransitionBackgroundImage = love.graphics.newImage("assets/art/day_transition_background.png")
    blinkTimer = 0
    showContinueText = true

    initializeSaveData()
    local saveData = Save.load()
    DayTracker.currentDay = saveData.currentDay
end

function DayTracker.unload() end

function DayTracker.onPause() end

function DayTracker.onResume() end

function DayTracker.keypressed(key, scancode, isRepeat)
    if Input.MODIFIER_KEYS:contains(key) then
        return
    end

    startDay()
end

function DayTracker.mousepressed(x, y, button, isTouch, presses) end

function DayTracker.mousemoved(x, y, dx, dy, isTouch) end

function DayTracker.wheelmoved(x, y) end

function DayTracker.update(dt)
    blinkTimer = blinkTimer + dt
    if blinkTimer > BLINK_HOLD_TIME then
        blinkTimer = 0
        showContinueText = not showContinueText
    end
end

function DayTracker.draw()
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

return DayTracker
