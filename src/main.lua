local draw = require("engine/draw")
local scene = require("engine/scene")

local mainMenu = require("game/main_menu")
local game = require("game/game")
local debug = require("game/debug")

function love.load()
	draw.load()

	scene.register("mainMenu", mainMenu)
	scene.register("game", game)
	scene.register("debug", debug)

	scene.start(scene.scenes.debug)
	scene.start(scene.scenes.mainMenu)
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
	draw.drawToCanvas(function()
		scene.draw()
	end
	)
end
