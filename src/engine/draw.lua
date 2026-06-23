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

	if drawComponent.setShader then
		drawComponent.setShader()
	else
		love.graphics.setShader()
	end

	local xOffset = drawComponent.xOffset or 0
	local yOffset = drawComponent.yOffset or 0
	if drawComponent.centered and drawComponent.image then
		local width, height = drawComponent.image:getDimensions()
		xOffset = xOffset - width / 2
		yOffset = yOffset - height / 2
	end

	if drawComponent.spriteBatch then
		love.graphics.draw(
			drawComponent.spriteBatch,
			xOffset,
			yOffset
		)
	elseif drawComponent.quad then
		love.graphics.draw(
			drawComponent.image,
			drawComponent.quad,
			xOffset,
			yOffset
		)
	elseif drawComponent.quads then
		love.graphics.draw(
			drawComponent.image,
			quad,
			xOffset,
			yOffset
		)
	else
		love.graphics.draw(
			drawComponent.image,
			xOffset,
			yOffset
		)
	end
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
