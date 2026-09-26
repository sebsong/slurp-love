local Save = require("engine.save")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")

local FIRST_DAY = 1
local FINAL_DAY = 5

---@class DayTracker: Scene
local DayTracker = Scene.new()
DayTracker.currentDay = FIRST_DAY
DayTracker.maxDay = FIRST_DAY

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

local function updateDaySaveData(currentDay)
    Save.update(function(saveData)
        saveData.currentDay = currentDay

        if currentDay > saveData.maxDay then
            saveData.maxDay = currentDay
        end
    end)
end

local function updateStatsSaveData(currentDay, gasRemaining, elapsedSeconds)
    Save.update(function(saveData)
        local currentDayStats = saveData.dayStats[currentDay]
        if gasRemaining > currentDayStats.gasRemaining then
            currentDayStats.gasRemaining = gasRemaining
        end

        if not currentDayStats.elapsedSeconds or elapsedSeconds < currentDayStats.elapsedSeconds then
            currentDayStats.elapsedSeconds = elapsedSeconds
        end
    end)
end

function DayTracker.nextDay(gasRemaining, elapsedSeconds)
    updateStatsSaveData(DayTracker.currentDay, gasRemaining, elapsedSeconds)

    if DayTracker.currentDay == FINAL_DAY then
        if not SceneManager.scenes.victoryMenu.isActive then
            SceneManager.scenes.victoryMenu:start()
        end
        return
    end

    DayTracker.selectDay(DayTracker.currentDay + 1)
end

function DayTracker.selectDay(day)
    DayTracker.currentDay = day
    DayTracker.maxDay = math.max(DayTracker.maxDay, day)
    updateDaySaveData(day)
    SceneManager.transition(SceneManager.scenes.dayTransition)
end

function DayTracker:load()
    initializeSaveData()
    local saveData = Save.load()
    DayTracker.currentDay = saveData.currentDay
    DayTracker.maxDay = saveData.maxDay
end

return DayTracker
