local draw = {}

local canvas = require("engine/canvas")

local canvasToScreenTransform
local shader

function draw.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function draw.loadShader(colorPalette)
	shader = love.graphics.newShader("assets/shader/color_swap.glsl")
end

function draw.draw(drawable)
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
	if drawable.quad then
		love.graphics.draw(drawable.image, drawable.quad, drawable.offsetX, drawable.offsetY)
	else
		love.graphics.draw(drawable.image, drawable.offsetX, drawable.offsetY)
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
	love.graphics.draw(canvas.canvas, canvasToScreenTransform)
end

return draw
