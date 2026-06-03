local draw = {}

local canvas = require("engine/canvas")
local shader = require("engine/shader")

function draw.load()
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)
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

	local quad
	if drawComponent.quad then
		quad = drawComponent.quad
	elseif drawComponent.quads then
		quad = drawComponent.quads[drawComponent.currentFrame]
	end

	local drawShader = drawComponent.shader
	if drawShader then
		if quad and drawShader:hasUniform(shader.QUAD_VIEWPORT_UNIFORM) then
			drawShader:send(shader.QUAD_VIEWPORT_UNIFORM, { drawComponent.quad:getViewport() })
		end
		love.graphics.setShader(drawShader)
	end

	if drawComponent.spriteBatch then
		love.graphics.draw(
			drawComponent.spriteBatch,
			drawComponent.xOffset,
			drawComponent.yOffset
		)
	elseif drawComponent.quad then
		love.graphics.draw(
			drawComponent.image,
			drawComponent.quad,
			drawComponent.xOffset,
			drawComponent.yOffset
		)
	elseif drawComponent.quads then
		love.graphics.draw(
			drawComponent.image,
			quad,
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
