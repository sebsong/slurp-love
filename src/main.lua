local scene = require("engine/scene")

local game = require("game/game")

function love.load()
	scene.register(game)

	scene.start(game)
end

function love.keypressed(key, scancode, isRepeat)
	scene.keypressed(key, scancode, isRepeat)
end

function love.mousepressed(x, y, button, isTouch, presses)
	scene.mousepressed(x, y, button, isTouch, presses)
end

function love.mousemoved(x, y, dx, dy, isTouch)
	scene.mousemoved(x, y, dx, dy, isTouch)
end

function love.wheelmoved(x, y)
	scene.wheelmoved(x, y)
end

function love.update(dt)
	scene.update(dt)
end

function love.draw()
	scene.draw()
end
