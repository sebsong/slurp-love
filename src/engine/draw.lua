local draw = {}

local canvas = require("engine/canvas")

local shader

function draw.load()
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function draw.loadShader(colorPalette)
	shader = love.graphics.newShader("assets/shader/color_swap.glsl")
end

function draw.draw(drawComponent, transform)
	if not drawComponent.shouldDraw then
		return
	end
	if drawComponent.draw then
		drawComponent.draw(drawComponent, transform)
		return
	end

	love.graphics.push()
	love.graphics.applyTransform(transform)
	-- shader:send("src_color", ColorPalette[3])
	-- shader:send("dst_color", ColorPalette[8])
	love.graphics.setShader(shader)
	if drawComponent.quad then
		love.graphics.draw(
			drawComponent.image,
			drawComponent.quad,
			drawComponent.xOffset,
			drawComponent.yOffset
		)
	elseif drawComponent.quads then
		love.graphics.draw(
			drawComponent.image,
			drawComponent.quads[drawComponent.currentFrame],
			drawComponent.xOffset,
			drawComponent.yOffset
		)
	else
		love.graphics.draw(
			drawComponent.image,
			drawComponent.xOffset,
			drawComponent.yOffset
		)
	end
	love.graphics.setShader()
	love.graphics.pop()
end

function draw.drawToCanvas(drawFunction)
	canvas.canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(canvas.scale, canvas.scale)

			drawFunction()

			love.graphics.pop()
		end
	)
	love.graphics.draw(canvas.canvas, canvas.scaledCanvasToScreenTransform)
end

return draw
