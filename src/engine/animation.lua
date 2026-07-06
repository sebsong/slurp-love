local animation = {}

local draw = require("engine/draw")

function animation.new(image, numFrames, xOffset, yOffset, zIndex, zIndexOffset)
	local quads = {}
	local imageWidth, imageHeight = image:getDimensions()
	local quadWidth, quadHeight = imageWidth / numFrames, imageHeight
	for i = 0, numFrames - 1 do
		table.insert(quads, love.graphics.newQuad(i * quadWidth, 0, quadWidth, quadHeight, image))
	end

	return draw.new(image, quads, xOffset, yOffset, zIndex, zIndexOffset)
end

return animation
