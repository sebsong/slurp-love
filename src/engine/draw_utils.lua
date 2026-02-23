require("engine/matrix")
require("engine/color")

local DARK_BLUE
local PURPLE
local DARK_RED
local BRIGHT_RED

local shader

function LoadShader(colorPalette)
	DARK_BLUE = colorPalette[2]
	PURPLE = colorPalette[3]
	DARK_RED = colorPalette[4]
	BRIGHT_RED = colorPalette[5]
	shader = love.graphics.newShader("assets/shader/color_swap.glsl")
end

function Draw(drawable)
	if not drawable.shouldDraw then
		return
	end

	if drawable.draw then
		drawable:draw()
		return
	end

	love.graphics.push()
	love.graphics.applyTransform(drawable.transform)
	-- shader:send("src_color", BRIGHT_RED)
	-- shader:send("dst_color", DARK_BLUE)
	love.graphics.setShader(shader)
	love.graphics.draw(drawable.image, drawable.quad, drawable.offsetX, drawable.offsetY)
	love.graphics.setShader()
	love.graphics.pop()
end
