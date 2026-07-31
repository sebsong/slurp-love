local DayTracker = {
	currentDay = 1,
	FINAL_DAY = 5,
}

local Settings = require("engine/settings")
local Scene = require("engine/scene")
local Save = require("engine/save")

local Font = require("game/font")

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

function DayTracker.isEndScreen()
	return DayTracker.currentDay > DayTracker.FINAL_DAY
end

local function startDay()
	if (DayTracker.isEndScreen()) then
		print("YOU WIN")
	else
		Scene.transition(Scene.scenes.game)
	end
end

function DayTracker.nextDay()
	DayTracker.currentDay = DayTracker.currentDay + 1
	Save.save({ currentDay = DayTracker.currentDay })
end

function DayTracker.load()
	dayTransitionBackgroundImage = love.graphics.newImage("assets/art/day_transition_background.png")
	blinkTimer = 0
	showContinueText = true

	local saveData = Save.load()
	if saveData.currentDay then
		DayTracker.currentDay = saveData.currentDay
	end
end

function DayTracker.unload()
end

function DayTracker.onPause()
end

function DayTracker.onResume()
end

function DayTracker.keypressed(key, scancode, isRepeat)
	startDay()
end

function DayTracker.mousepressed(x, y, button, isTouch, presses)
end

function DayTracker.mousemoved(x, y, dx, dy, isTouch)
end

function DayTracker.wheelmoved(x, y)
end

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
	if DayTracker.isEndScreen() then
		love.graphics.printf(
			string.format("you win", DayTracker.currentDay),
			0,
			2 * Font.large:getHeight(),
			Settings.canvasPixelWidth,
			"center"
		)
	else
		love.graphics.printf(
			DAY_TO_NAME[DayTracker.currentDay],
			0,
			2 * Font.large:getHeight(),
			Settings.canvasPixelWidth,
			"center"
		)
	end

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
