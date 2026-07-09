local draw = {}

local canvas = require("engine/canvas")

function draw.load()
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function draw.new(image, quad, xOffset, yOffset, zIndex, zIndexOffset)
	local isQuadArray = type(quad) == "table"
	local currentFrame = 1
	local width, height
	if quad then
		local referenceQuad = isQuadArray and quad[currentFrame] or quad
		_, _, width, height = referenceQuad:getViewport()
	else
		if image.getDimensions then
			width, height = image:getDimensions()
		else
			width, height = 0, 0 -- TODO: fix for sprite batches
		end
	end
	return {
		shouldDraw = true,
		image = image,
		quad = not isQuadArray and quad or nil,
		quads = isQuadArray and quad or nil,
		currentFrame = currentFrame,
		width = width,
		height = height,
		xOffset = xOffset,
		yOffset = yOffset,
		zIndex = zIndex,
		zIndexOffset = zIndexOffset,

		setShader = nil,
		draw = nil,
	}
end

function draw.newSpriteBatch(spriteBatch, zIndex, zIndexOffset)
	return draw.new(spriteBatch, nil, nil, nil, zIndex, zIndexOffset, false)
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

	if drawComponent.setShader then
		drawComponent.setShader()
	else
		love.graphics.setShader()
	end

	local quad
	if drawComponent.quad then
		quad = drawComponent.quad
	elseif drawComponent.quads then
		quad = drawComponent.quads[drawComponent.currentFrame]
	end

	if quad then
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
