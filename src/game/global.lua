local Global = {}

local Scene = require("engine/scene")

function Global.load()
end

function Global.unload()
end

function Global.onPause()
end

function Global.onResume()
end

function Global.keypressed(key, scancode, isRepeat)
	local gameScene = Scene.scenes.game
	if gameScene.isActive and love.keyboard.isDown("escape") and not isRepeat then
		Scene.scenes.pauseMenu.toggle()
	end
end

function Global.mousepressed(x, y, button, isTouch, presses)
end

function Global.mousemoved(x, y, dx, dy, isTouch)
end

function Global.wheelmoved(x, y)
end

function Global.update(dt)
end

function Global.draw()
end

return Global
