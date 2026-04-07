require("engine/settings")
require("engine/color")
require("engine/camera")
require("engine/draw_utils")
local collision = require("engine/collision")
local scene = require("engine/scene")

local game = require("game/game")
require("game/boat")
require("game/package")
local ui = require("game/ui")
local music = require("game/music")
local game = require("game/game")

function love.load()
	scene.register(game)

	scene.start(game)
end

-- function love.keypressed(key, scancode, isRepeat)
-- 	if key == "space" and not isRepeat then
-- 		if not Boat:pickupPackages(Packages) then
-- 			Boat:deliverPackage(Mailboxes)
-- 		end
-- 	end

-- 	Camera:keypressed(key, scancode, isRepeat)
-- end

-- function love.mousepressed(x, y, button, isTouch, presses)
-- 	Camera:mousepressed(x, y, button, isTouch, presses)
-- end

-- function love.mousemoved(x, y, dx, dy, isTouch)
-- 	Camera:mousemoved(x, y, dx, dy, isTouch)
-- end

-- function love.wheelmoved(x, y)
-- 	Camera:wheelmoved(x, y)
-- end

function love.update(dt)
	scene.update(dt)
end

function love.draw()
	scene.draw()
end
