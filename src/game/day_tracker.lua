local dayTracker = {
	currentDay = 1
}

local settings = require("engine/settings")
local scene = require("engine/scene")
local font = require("game/font")

local dayTransitionBackgroundImage

local showContinueText = true
local blinkTimer = 0
local BLINK_HOLD_TIME = 1

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
	blinkTimer = blinkTimer + dt
	if blinkTimer > BLINK_HOLD_TIME then
		blinkTimer = 0
		showContinueText = not showContinueText
	end
end

function dayTracker.draw()
	love.graphics.setFont(font.default)
	love.graphics.draw(dayTransitionBackgroundImage)
	love.graphics.printf(
		string.format("day %s", dayTracker.currentDay),
		0,
		2 * font.default:getHeight(),
		settings.canvasPixelWidth,
		"center"
	)

	if showContinueText then
		love.graphics.setFont(font.small)
		love.graphics.printf(
			string.format("press any button to continue", dayTracker.currentDay),
			0,
			settings.canvasPixelHeight - (4 * font.small:getHeight()),
			settings.canvasPixelWidth,
			"center"
		)
	end
end

return dayTracker
