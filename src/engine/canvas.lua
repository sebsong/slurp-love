local Canvas = {
	scale = nil,
	scaledCanvasToScreenTransform = nil,
	canvasToScreenTransform = nil,
	screenToCanvasTransform = nil,
	canvas = nil,
}

local Settings = require("engine/settings")

function Canvas.load()
	local screenWidth, screenHeight = love.graphics.getDimensions()
	Canvas.scale = math.min(screenWidth / Settings.canvasPixelWidth, screenHeight / Settings.canvasPixelHeight)
	-- if Canvas.scale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- Canvas.scale = math.floor(Canvas.scale)
	-- end

	local canvasWidth = Settings.canvasPixelWidth * Canvas.scale
	local canvasHeight = Settings.canvasPixelHeight * Canvas.scale
	local xAdjust = (screenWidth - canvasWidth) / 2
	local yAdjust = (screenHeight - canvasHeight) / 2

	Canvas.scaledCanvasToScreenTransform = love.math.newTransform(
		xAdjust,
		yAdjust
	)

	Canvas.canvasToScreenTransform = love.math.newTransform(
		xAdjust,
		yAdjust,
		0,
		Canvas.scale,
		Canvas.scale
	)
	Canvas.screenToCanvasTransform = Canvas.canvasToScreenTransform:inverse()

	Canvas.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
end

function Canvas.draw(drawFunction)
	Canvas.canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(Canvas.scale, Canvas.scale)

			drawFunction()

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas.canvas, Canvas.scaledCanvasToScreenTransform)
end

return Canvas
