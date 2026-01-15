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

	WorldTransform = love.math.newTransform(CanvasWidth / 2, CanvasHeight / 2)

	local boatWidth, boatHeight = 32, 32
	BoatQuad = love.graphics.newQuad(0, 0, boatWidth, boatHeight, EntitiesImage:getWidth(), EntitiesImage:getHeight())
	BoatTransform = love.math.newTransform(0, 0, 0, 1, 1, boatWidth / 2, boatHeight / 2)
	Speed = 300
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
		BoatTransform:translate(0, -Speed * dt)
	end
	if love.keyboard.isDown("down") then
		BoatTransform:translate(0, Speed * dt)
	end
	if love.keyboard.isDown("left") then
		BoatTransform:rotate(-RotSpeed * dt)
	end
	if love.keyboard.isDown("right") then
		BoatTransform:rotate(RotSpeed * dt)
	end
end

function love.draw()
	Canvas:renderTo(function()
		love.graphics.draw(BackgroundImage)

		love.graphics.push()
		love.graphics.applyTransform(WorldTransform)

		love.graphics.draw(EntitiesImage, BoatQuad, BoatTransform)
		love.graphics.points(0, 0)

		love.graphics.pop()
	end)
	love.graphics.draw(Canvas, 0, 0, 0, CanvasScaleX, CanvasScaleY)
end
