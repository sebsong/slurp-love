local dayTracker = {
	currentDay = 1,
	FINAL_DAY = 5,
}

local settings = require("engine/settings")
local scene = require("engine/scene")
local font = require("game/font")

local DAY_TO_NAME = {
	"monday",
	"tuesday",
	"wednesday",
	"thursday",
	"friday",
}

local dayTransitionBackgroundImage

local showContinueText
local blinkTimer
local BLINK_HOLD_TIME = 1

function dayTracker.isEndScreen()
	return dayTracker.currentDay > dayTracker.FINAL_DAY
end

local function startDay()
	if (dayTracker.isEndScreen()) then
		print("YOU WIN")
	else
		scene.transition(scene.scenes.game)
	end
end

function dayTracker.nextDay()
	dayTracker.currentDay = dayTracker.currentDay + 1
end

function dayTracker.load()
	dayTransitionBackgroundImage = love.graphics.newImage("assets/art/day_transition_background.png")
	blinkTimer = 0
	showContinueText = true
end

function dayTracker.unload()
end

function dayTracker.keypressed(key, scancode, isRepeat)
	startDay()
end

function dayTracker.mousepressed(x, y, button, isTouch, presses)
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
	love.graphics.setFont(font.large)
	love.graphics.draw(dayTransitionBackgroundImage)
	if dayTracker.isEndScreen() then
		love.graphics.printf(
			string.format("you win", dayTracker.currentDay),
			0,
			2 * font.large:getHeight(),
			settings.canvasPixelWidth,
			"center"
		)
	else
		love.graphics.printf(
			DAY_TO_NAME[dayTracker.currentDay],
			0,
			2 * font.large:getHeight(),
			settings.canvasPixelWidth,
			"center"
		)
	end

	if showContinueText then
		love.graphics.setFont(font.medium)
		love.graphics.printf(
			string.format("press any button to continue", dayTracker.currentDay),
			0,
			settings.canvasPixelHeight - (4 * font.medium:getHeight()),
			settings.canvasPixelWidth,
			"center"
		)
	end
end

return dayTracker
