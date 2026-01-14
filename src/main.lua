require("game/settings")
TLfres = require("external/tlfres")

function love.load()
	ColorPalette = {}
	for hexColor in love.filesystem.lines("assets/art/look-of-horror.hex") do
		table.insert(ColorPalette, hexColor)
	end

	BackgroundImage = love.graphics.newImage("assets/art/background.png")
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	BoatQuad = love.graphics.newQuad(0, 0, 32, 32, EntitiesImage:getWidth(), EntitiesImage:getHeight())

	local width, height = love.graphics.getDimensions()
	Pos = { x = width / 2, y = height / 2 }
	Speed = 300
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
	-- TLfres.beginRendering(DisplayWidth, DisplayHeight)
	love.graphics.draw(BackgroundImage)
	love.graphics.draw(EntitiesImage, BoatQuad, Pos.x, Pos.y)
	-- TLfres.endRendering()
end
