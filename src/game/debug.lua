local debug = {}

local scene = require("engine/scene")

local font = require("game/font")

function debug.load()
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
end

function debug.draw()
	love.graphics.setFont(font.small)
	love.graphics.setColor(1, 0, 0)
	love.graphics.print(string.format("fps: %s", love.timer.getFPS()))
	love.graphics.setColor(1, 1, 1)
end

return debug
