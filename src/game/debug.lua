local debug = {}

local scene = require("engine/scene")

local profile = require("external/profile")

local defaultFont
local frame
local report

function debug.load()
	defaultFont = love.graphics.getFont()
	frame = 0
	profile.start()
end

function debug.unload()
end

function debug.keypressed(key, scancode, isRepeat)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if key == "tab" and not isRepeat then
		if scene.scenes.mainMenu.isActive then
			scene.transition(scene.scenes.mainMenu, scene.scenes.dayTracker)
		elseif scene.scenes.game.isActive then
			scene.scenes.game.endDay()
		end
	end
end

function debug.mousepressed(x, y, button, isTouch, presses)
	if button == 1 and scene.scenes.game.isActive then
		scene.scenes.game.debugTeleportBoatToCanvasPoint(x, y)
	end
end

function debug.mousemoved(x, y, dx, dy, isTouch)
end

function debug.wheelmoved(x, y)
end

function debug.update(dt)
	frame = frame + 1
	if frame % 1000 == 0 then
		report = profile.report(20)
		profile.reset()
		-- print(report)
	end
end

function debug.draw()
	love.graphics.setFont(defaultFont)

	love.graphics.setColor(0, 1, 0)
	love.graphics.print(string.format("fps: %s", love.timer.getFPS()))
	love.graphics.setColor(1, 1, 1)
end

return debug
