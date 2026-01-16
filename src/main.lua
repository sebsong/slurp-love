require("game/settings")
require("engine/math")

function love.load()
	Canvas = love.graphics.newCanvas(CanvasWidth, CanvasHeight)
	Canvas:setFilter("nearest", "nearest")

	ColorPalette = {}
	for hexColor in love.filesystem.lines("assets/art/look-of-horror.hex") do
		table.insert(ColorPalette, hexColor)
	end

	WorldTransform = love.math.newTransform(CanvasWidth / 2, CanvasHeight / 2)

	BackgroundImage = love.graphics.newImage("assets/art/background.png")
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	local entitiesImageWidth = EntitiesImage:getWidth()
	local entitiesImageHeight = EntitiesImage:getHeight()

	BackgroundQuad = love.graphics.newQuad(0, 0, CanvasWidth, CanvasHeight, entitiesImageWidth, entitiesImageHeight)

	local boatWidth, boatHeight = 32, 32
	BoatQuad = love.graphics.newQuad(0, 0, boatWidth, boatHeight, entitiesImageWidth, entitiesImageHeight)
	BoatTransform = love.math.newTransform(0, 0, 0, 1, 1, boatWidth / 2, boatHeight / 2)
	Speed = 300
	Rot = 0
	RotSpeed = 2 * PI

	local windowWidth, windowHeight = love.graphics.getDimensions()
	CanvasScale = math.floor(windowHeight / CanvasHeight)
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
		-- Rot = Rot - RotSpeed * dt
		BoatTransform:rotate(-RotSpeed * dt)
	end
	if love.keyboard.isDown("right") then
		-- Rot = Rot + RotSpeed * dt
		BoatTransform:rotate(RotSpeed * dt)
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(CanvasScale, CanvasScale)
	love.graphics.draw(BackgroundImage, BackgroundQuad)
	love.graphics.applyTransform(WorldTransform)

	love.graphics.draw(EntitiesImage, BoatQuad, BoatTransform)
	love.graphics.points(0, 0)

	love.graphics.pop()
end
