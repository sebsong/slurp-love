local mainMenu = {}

local backgroundImage
local buttonImage

function mainMenu.load()
	backgroundImage = love.graphics.newImage("assets/art/main_menu.png")
	buttonImage = love.graphics.newImage("assets/art/button.png")
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
	love.graphics.draw(buttonImage, 75, 175)
	love.graphics.draw(buttonImage, 75, 250)
end

return mainMenu
