function love.load()
	entitiesImage = love.graphics.newImage("assets/art/entities.png")
	rectPos = { x = 100, y = 100 }
	speed = 300
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if love.keyboard.isDown("up") then
		rectPos.y = rectPos.y - speed * dt;
	end
	if love.keyboard.isDown("down") then
		rectPos.y = rectPos.y + speed * dt;
	end
	if love.keyboard.isDown("left") then
		rectPos.x = rectPos.x - speed * dt;
	end
	if love.keyboard.isDown("right") then
		rectPos.x = rectPos.x + speed * dt;
	end
end

function love.draw()
	love.graphics.draw(entitiesImage)
	love.graphics.rectangle("fill", rectPos.x, rectPos.y, 50, 80)
end
