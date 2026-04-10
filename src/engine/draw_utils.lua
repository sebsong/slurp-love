local shader

function LoadShader(colorPalette)
	shader = love.graphics.newShader("assets/shader/color_swap.glsl")
end

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
	-- shader:send("src_color", ColorPalette[3])
	-- shader:send("dst_color", ColorPalette[8])
	love.graphics.setShader(shader)
	love.graphics.draw(drawable.image, drawable.quad, drawable.offsetX, drawable.offsetY)
	love.graphics.setShader()
	love.graphics.pop()
end
