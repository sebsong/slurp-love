local draw = {
	canvas = nil
}

local settings = require("engine/settings")

local screenScale
local canvasToScreenTransform
local shader

function draw.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)

	local windowWidth, windowHeight = love.graphics.getDimensions()
	screenScale = math.min(windowWidth / settings.baseCanvasWidth, windowHeight / settings.baseCanvasHeight)

	-- if ScreenScale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- ScreenScale = math.floor(ScreenScale)
	-- end

	local canvasWidth = settings.baseCanvasWidth * screenScale
	local canvasHeight = settings.baseCanvasHeight * screenScale
	draw.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	canvasToScreenTransform = love.math.newTransform(
		(windowWidth - canvasWidth) / 2,
		(windowHeight - canvasHeight) / 2,
		0
	)
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
	love.graphics.draw(drawable.image, drawable.quad, drawable.offsetX, drawable.offsetY)
	love.graphics.setShader()
	love.graphics.pop()
end

function draw.drawToCanvas(drawFunction)
	draw.canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(screenScale, screenScale)

			drawFunction()

			love.graphics.pop()
		end
	)
	love.graphics.draw(draw.canvas, canvasToScreenTransform)
end

return draw
