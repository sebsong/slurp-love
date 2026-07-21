local global = {}

local scene = require("engine/scene")

function global.load()
end

function global.unload()
end

function global.keypressed(key, scancode, isRepeat)
	local gameScene = scene.scenes.game
	if gameScene.isActive and love.keyboard.isDown("escape") and not isRepeat then
		scene.scenes.pauseMenu.toggle()
	end
end

function global.mousepressed(x, y, button, isTouch, presses)
end

function global.mousemoved(x, y, dx, dy, isTouch)
end

function global.wheelmoved(x, y)
end

function global.update(dt)
end

function global.draw()
end

return global
