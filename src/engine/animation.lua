local animation = {}

function animation.new(image, numFrames, xOffset, yOffset)
	local quads = {}
	local imageWidth, imageHeight = image:getDimensions()
	local quadWidth, quadHeight = imageWidth / numFrames, imageHeight
	for i = 0, numFrames - 1 do
		table.insert(quads, love.graphics.newQuad(i * quadWidth, 0, quadWidth, quadHeight, image))
	end

	return {
		image = image,
		quads = quads,
		xOffset = xOffset,
		yOffset = yOffset,
		shouldDraw = true,
		currentFrame = 1
	}
end

return animation
