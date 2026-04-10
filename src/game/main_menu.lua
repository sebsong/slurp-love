local mainMenu = {}

local scene = require("engine/scene")

local backgroundImage

function mainMenu.load()
	backgroundImage = love.graphics.newImage("assets/art/main_menu.png")
end

function mainMenu.unload()
end

function mainMenu.keypressed(key, scancode, isRepeat)
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
	love.graphics.draw(backgroundImage)
end

return mainMenu
