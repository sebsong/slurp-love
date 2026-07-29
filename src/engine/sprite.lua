local Sprite = {}

function Sprite.load()
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function Sprite.new(image, quad, xOffset, yOffset, zIndex, zIndexOffset, isSpriteBatch)
	local isQuadArray = type(quad) == "table"
	local currentFrame = 1
	local width, height
	if quad then
		local referenceQuad = isQuadArray and quad[currentFrame] or quad
		_, _, width, height = referenceQuad:getViewport()
	else
		width, height = image:getDimensions()
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
		isSpriteBatch = isSpriteBatch,

		setShader = nil,
		draw = nil,
	}
end

function Sprite.newSpriteBatch(spriteBatch, quad, zIndex, zIndexOffset)
	return Sprite.new(spriteBatch, quad, nil, nil, zIndex, zIndexOffset, true)
end

function Sprite.draw(sprite, transform)
	if not sprite.shouldDraw then
		return
	end

	if sprite.draw then
		sprite.draw(sprite, transform)
		return
	end

	love.graphics.push()
	love.graphics.applyTransform(transform)

	if sprite.setShader then
		sprite.setShader()
	else
		love.graphics.setShader()
	end

	local quad
	if sprite.quad then
		quad = sprite.quad
	elseif sprite.quads then
		quad = sprite.quads[sprite.currentFrame]
	end

	if quad and not sprite.isSpriteBatch then
		love.graphics.draw(
			sprite.image,
			quad,
			sprite.xOffset,
			sprite.yOffset
		)
	else
		love.graphics.draw(
			sprite.image,
			sprite.xOffset,
			sprite.yOffset
		)
	end
	love.graphics.pop()
end

return Sprite
