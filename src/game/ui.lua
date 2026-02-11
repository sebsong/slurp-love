require("engine/settings")

local gasMeterWidth, gasMeterHeight = 16, 128

-- TODO: don't draw ui elements centered, have some utility for doing math for right/left aligned padding
local packageContainerWidth, packageContainerHeight = 20, 74
local padding = 10
local packageUiLocation = {
	x = BaseCanvasWidth - padding - packageContainerWidth / 2,
	y = BaseCanvasHeight - padding - packageContainerHeight / 2
}
local packageUiVerticalSpacing = -18
local packageOffsetYInitial = packageContainerHeight / 2 - 10

local ui = {}

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
	local _, _, gasMeterWidth, gasMeterHeight = ui.gasMeterQuad:getViewport()
	love.graphics.draw(ui.image, ui.gasMeterQuad, padding, BaseCanvasHeight - gasMeterHeight - padding)
	love.graphics.setShader(ui.gasMeterShader)
	love.graphics.draw(ui.image, ui.gasMeterProgressQuad, padding, BaseCanvasHeight - gasMeterHeight - padding)
	love.graphics.setShader()

	local _, _, width, height = ui.packageContainerQuad:getViewport()
	love.graphics.draw(
		ui.image,
		ui.packageContainerQuad,
		packageUiLocation.x - width / 2, packageUiLocation.y - height / 2
	)
	local packageOffsetY = packageOffsetYInitial
	for _, package in ipairs(packages) do
		local _, _, width, height = package.quad:getViewport()
		love.graphics.draw(
			package.image,
			package.quad,
			packageUiLocation.x - width / 2,
			packageUiLocation.y - height / 2 + packageOffsetY
		)
		packageOffsetY = packageOffsetY + packageUiVerticalSpacing
	end
end

return ui
