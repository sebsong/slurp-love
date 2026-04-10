local mainMenu = {}

local scene = require("engine/scene")
local game = require("game/game")

function mainMenu.load()
end

function mainMenu.unload()
end

function mainMenu.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		scene.transition(mainMenu, game)
	end
end

function mainMenu.mousepressed(x, y, button, isTouch, presses)
end

function mainMenu.mousemoved(x, y, dx, dy, isTouch)
end

function mainMenu.wheelmoved(x, y)
end

function mainMenu.update(dt)
end

function mainMenu.draw()
end

return mainMenu
