local map = {}

local draw = require("engine/draw")
local animation = require("engine/animation")
local ui = require("engine/ui")
local scene = require("engine/scene")

local font = require("game/font")
local gameUi = require("game/ui")

local mapOverlay

function map.open()
	scene.start(scene.scenes.map)
end

function map.close()
	scene.stop(scene.scenes.map)
end

function map.load()
	local mapImage = love.graphics.newImage("assets/art/map.png")
	local mapDrawComponent = draw.new(mapImage)
	mapOverlay = {
		drawComponent = mapDrawComponent,
		transform = ui.newAlignedTransform(mapDrawComponent.width, mapDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}
end

function map.unload()
end

function map.keypressed(key, scancode, isRepeat)
end

function map.mousepressed(x, y, button, isTouch, presses)
end

function map.mousemoved(x, y, dx, dy, isTouch)
end

function map.wheelmoved(x, y)
end

function map.update(dt)
end

function map.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(mapOverlay.drawComponent, mapOverlay.transform)

	love.graphics.pop()
end

return map
