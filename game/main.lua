function love.load()
end

function love.update()
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function love.draw()
	local width, height = love.graphics.getDimensions()
	love.graphics.print("slurp's up", width / 2, height / 2)
end
