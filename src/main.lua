function love.load()
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
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
	love.graphics.draw(EntitiesImage, Pos.x, Pos.y)
end
