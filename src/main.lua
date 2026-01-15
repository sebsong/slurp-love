require("game/settings")
require("engine/math")

function love.load()
	Canvas = love.graphics.newCanvas(CanvasWidth, CanvasHeight)
	Canvas:setFilter("nearest", "nearest")

	ColorPalette = {}
	for hexColor in love.filesystem.lines("assets/art/look-of-horror.hex") do
		table.insert(ColorPalette, hexColor)
	end

	BackgroundImage = love.graphics.newImage("assets/art/background.png")
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")

	BoatQuad = love.graphics.newQuad(0, 0, 32, 32, EntitiesImage:getWidth(), EntitiesImage:getHeight())
	Pos = { x = 0, y = 0 }
	Speed = 300
	Rot = 0
	RotSpeed = 2 * PI

	local windowWidth, windowHeight = love.graphics.getDimensions()
	CanvasScaleX = windowWidth / CanvasWidth
	CanvasScaleY = windowHeight / CanvasHeight
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if love.keyboard.isDown("up") then
		Pos.y = Pos.y - Speed * dt
	end
	if love.keyboard.isDown("down") then
		Pos.y = Pos.y + Speed * dt
	end
	if love.keyboard.isDown("left") then
		Rot = Rot - RotSpeed * dt
	end
	if love.keyboard.isDown("right") then
		Rot = Rot + RotSpeed * dt
	end
end

function love.draw()
	Canvas:renderTo(function()
		love.graphics.draw(BackgroundImage)

		love.graphics.push()
		love.graphics.translate(CanvasWidth / 2, CanvasHeight / 2)

		local _, _, width, height = BoatQuad:getViewport()
		love.graphics.draw(EntitiesImage, BoatQuad, Pos.x, Pos.y, Rot, 1, 1, width / 2, height / 2)

		love.graphics.pop()
	end)
	love.graphics.draw(Canvas, 0, 0, 0, CanvasScaleX, CanvasScaleY)
end
