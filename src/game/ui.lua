local ui = {}

local settings = require("engine/settings")
local draw = require("engine/draw")

local gasMeterWidth, gasMeterHeight = 16, 128

-- TODO: don't draw ui elements centered, have some utility for doing math for right/left aligned padding
local packageContainerWidth, packageContainerHeight = 20, 74
local padding = 10
local packageUiLocation = {
	x = settings.canvasPixelWidth - padding - packageContainerWidth,
	y = settings.canvasPixelHeight - padding - packageContainerHeight
}
local packageUiVerticalSpacing = -18
local packageOffsetXInitial = 2
local packageOffsetYInitial = packageContainerHeight + packageUiVerticalSpacing

function ui.load(self)
	ui.image = love.graphics.newImage("assets/art/ui.png")
	ui.gasMeterQuad = love.graphics.newQuad(
		0, 0,
		gasMeterWidth, gasMeterHeight,
		ui.image:getWidth(), ui.image:getHeight()
	)
	ui.gasMeterProgressQuad = love.graphics.newQuad(
		gasMeterWidth, 0,
		gasMeterWidth, gasMeterHeight,
		ui.image:getWidth(), ui.image:getHeight()
	)
	ui.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
	ui.gasMeterShader:send("progress", 1.0)

	ui.packageContainerQuad = love.graphics.newQuad(
		32, 54,
		packageContainerWidth, packageContainerHeight,
		ui.image:getWidth(), ui.image:getHeight()
	)
end

function ui.draw(self, packages)
	love.graphics.setShader()

	local _, _, gasMeterWidth, gasMeterHeight = ui.gasMeterQuad:getViewport()
	love.graphics.draw(ui.image, ui.gasMeterQuad, padding, settings.canvasPixelHeight - gasMeterHeight - padding)
	love.graphics.setShader(ui.gasMeterShader)
	love.graphics.draw(ui.image, ui.gasMeterProgressQuad, padding, settings.canvasPixelHeight - gasMeterHeight - padding)
	love.graphics.setShader()

	love.graphics.draw(
		ui.image,
		ui.packageContainerQuad,
		packageUiLocation.x, packageUiLocation.y
	)
	local packageOffsetY = packageOffsetYInitial
	for _, package in ipairs(packages) do
		love.graphics.draw(
			package.drawComponent.image,
			package.drawComponent.quad,
			packageUiLocation.x + packageOffsetXInitial,
			packageUiLocation.y + packageOffsetY
		)
		packageOffsetY = packageOffsetY + packageUiVerticalSpacing
	end
end

return ui
