local debug = {}

local Scene = require("engine/scene")

local Profile = require("external/profile")

local ENABLE_PROFILER = false

local defaultFont
local frame
local report

function debug.load()
	defaultFont = love.graphics.getFont()
	frame = 0
	if ENABLE_PROFILER then
		Profile.start()
	end
end

function debug.unload()
end

function debug.onPause()
end

function debug.onResume()
end

function debug.keypressed(key, scancode, isRepeat)
	if key == "return" and not isRepeat then
		if Scene.scenes.mainMenu.isActive then
			Scene.transition(Scene.scenes.dayTracker)
		elseif Scene.scenes.game.isActive then
			Scene.scenes.game.endDay()
		end
	end
end

function debug.mousepressed(x, y, button, isTouch, presses)
	if button == 1 and Scene.scenes.game.isActive and not Scene.scenes.game.isPaused then
		Scene.scenes.game.debugTeleportBoatToCanvasPoint(x, y)
	end
end

function debug.mousemoved(x, y, dx, dy, isTouch)
end

function debug.wheelmoved(x, y)
end

function debug.update(dt)
	if ENABLE_PROFILER then
		frame = frame + 1
		if frame % 1000 == 0 then
			report = Profile.report(20)
			Profile.reset()
			print(report)
		end
	end
end

function debug.draw()
	love.graphics.setFont(defaultFont)

	love.graphics.setColor(0, 1, 0)
	love.graphics.print(string.format("fps: %s", love.timer.getFPS()))
	love.graphics.setColor(1, 1, 1)
end

return debug
