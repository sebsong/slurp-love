local Debug = {}

local Scene = require("engine/scene")

local DayTracker = require("game/day_tracker")
local Game = require("game/game")
local MainMenu = require("game/main_menu")

local Profile = require("external/profile")

local ENABLE_PROFILER = false

local defaultFont
local frame
local report

function Debug.load()
    defaultFont = love.graphics.getFont()
    frame = 0
    if ENABLE_PROFILER then
        Profile.start()
    end
end

function Debug.unload() end

function Debug.onPause() end

function Debug.onResume() end

function Debug.keypressed(key, scancode, isRepeat)
    if key == "return" and not isRepeat then
        if MainMenu.isActive then
            Scene.transition(DayTracker)
        elseif not DayTracker.isActive then
            DayTracker.nextDay(0)
        end
    end
end

function Debug.mousepressed(x, y, button, isTouch, presses)
    if button == 1 and Game.isActive and not Game.isPaused then
        Game.debugTeleportBoatToCanvasPoint(x, y)
    end
end

function Debug.mousemoved(x, y, dx, dy, isTouch) end

function Debug.wheelmoved(x, y) end

function Debug.update(dt)
    if ENABLE_PROFILER then
        frame = frame + 1
        if frame % 1000 == 0 then
            report = Profile.report(20)
            Profile.reset()
            print(report)
        end
    end
end

function Debug.draw()
    love.graphics.setFont(defaultFont)

    love.graphics.setColor(0, 1, 0)
    love.graphics.print(string.format("fps: %s", love.timer.getFPS()))
    love.graphics.setColor(1, 1, 1)
end

return Debug
