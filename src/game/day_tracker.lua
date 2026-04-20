local dayTracker = {
	currentDay = 1
}

local scene = require("engine/scene")
local font = require("game/font")

local dayTransitionBackgroundImage
local blinkTimer

function dayTracker.nextDay()
	dayTracker.currentDay = dayTracker.currentDay + 1
end

function dayTracker.load()
	dayTransitionBackgroundImage = love.graphics.newImage("assets/art/day_transition_background.png")
end

function dayTracker.unload()
end

function dayTracker.keypressed(key, scancode, isRepeat)
	scene.transition(scene.scenes.dayTracker, scene.scenes.game)
end

function dayTracker.mousepressed(x, y, button, isTouch, presses)
	scene.transition(scene.scenes.dayTracker, scene.scenes.game)
end

function dayTracker.mousemoved(x, y, dx, dy, isTouch)
end

function dayTracker.wheelmoved(x, y)
end

function dayTracker.update(dt)
end

function dayTracker.draw()
	love.graphics.setFont(font.default)
	love.graphics.draw(dayTransitionBackgroundImage)
	love.graphics.print(string.format("day %s", dayTracker.currentDay), 300, 100)
	love.graphics.print(string.format("press any button to continue", dayTracker.currentDay), 0, 200)
end

return dayTracker
