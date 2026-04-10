local debug = {}

local scene = require("engine/scene")

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
			scene.transition(scene.scenes.mainMenu, scene.scenes.game)
		else
			scene.transition(scene.scenes.game, scene.scenes.mainMenu)
		end
	end
end

function debug.mousepressed(x, y, button, isTouch, presses)
end

function debug.mousemoved(x, y, dx, dy, isTouch)
end

function debug.wheelmoved(x, y)
end

function debug.update(dt)
end

function debug.draw()
end

return debug
