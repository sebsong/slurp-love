local canvas = {
	scale = nil,
	scaledCanvasToScreenTransform = nil,
	canvasToScreenTransform = nil,
	screenToCanvasTransform = nil,
	canvas = nil,
}

local settings = require("engine/settings")

function canvas.load()
	local screenWidth, screenHeight = love.graphics.getDimensions()
	canvas.scale = math.min(screenWidth / settings.canvasPixelWidth, screenHeight / settings.canvasPixelHeight)
	-- if canvas.scale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- canvas.scale = math.floor(canvas.scale)
	-- end

	local canvasWidth = settings.canvasPixelWidth * canvas.scale
	local canvasHeight = settings.canvasPixelHeight * canvas.scale
	local xAdjust = (screenWidth - canvasWidth) / 2
	local yAdjust = (screenHeight - canvasHeight) / 2

	canvas.scaledCanvasToScreenTransform = love.math.newTransform(
		xAdjust,
		yAdjust
	)

	canvas.canvasToScreenTransform = love.math.newTransform(
		xAdjust,
		yAdjust,
		0,
		canvas.scale,
		canvas.scale
	)
	canvas.screenToCanvasTransform = canvas.canvasToScreenTransform:inverse()

	canvas.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
end

return canvas
