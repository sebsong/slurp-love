require("game/settings")

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
	Pos = { x = CanvasWidth / 2, y = CanvasHeight / 2 }
	Speed = 300

	local windowWidth, windowHeight = love.graphics.getDimensions()
	CanvasScaleX = windowWidth / CanvasWidth
	CanvasScaleY = windowHeight / CanvasHeight
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if love.keyboard.isDown("up") then
		Pos.y = Pos.y - Speed * dt;
	end
	if love.keyboard.isDown("down") then
		Pos.y = Pos.y + Speed * dt;
	end
	if love.keyboard.isDown("left") then
		Pos.x = Pos.x - Speed * dt;
	end
	if love.keyboard.isDown("right") then
		Pos.x = Pos.x + Speed * dt;
	end
end

function love.draw()
	Canvas:renderTo(function()
		love.graphics.draw(BackgroundImage)
		love.graphics.draw(EntitiesImage, BoatQuad, Pos.x, Pos.y)
	end)
	love.graphics.draw(Canvas, 0, 0, 0, CanvasScaleX, CanvasScaleY)
end
