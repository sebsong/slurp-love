function Draw(drawable)
	if not drawable.shouldDraw then
		return
	end

	if drawable.draw then
		drawable:draw()
		return
	end

	love.graphics.push()
	love.graphics.applyTransform(drawable.transform)
	love.graphics.draw(drawable.image, drawable.quad, drawable.offsetX, drawable.offsetY)
	love.graphics.pop()
end
