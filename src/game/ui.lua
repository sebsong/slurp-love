local ui = {}

local settings = require("engine/settings")
local packageEffect = require("game/package_effect")
local draw = require("engine/draw")
local ui = require("engine/ui")

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

local gasMeter
local gasMeterProgress
local packageContainer

function ui.load()
	local uiImage = love.graphics.newImage("assets/art/ui.png")
	local gasMeterQuad = love.graphics.newQuad(
		0, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	local gasMeterDrawComponent = draw.new(uiImage, gasMeterQuad)
	gasMeter = {
		drawComponent = gasMeterDrawComponent,
		transform = ui.newAlignedTransform(gasMeterDrawComponent, ui.align.LEFT, ui.align.BOTTOM, padding, -padding)
	}

	local gasMeterProgressQuad = love.graphics.newQuad(
		gasMeterWidth, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	ui.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
	ui.gasMeterShader:send("progress", 1.0)
	local gasMeterProgressDrawComponent = draw.new(uiImage, gasMeterProgressQuad)
	gasMeterProgressDrawComponent.setShader = function() love.graphics.setShader(ui.gasMeterShader) end
	gasMeterProgress = {
		drawComponent = gasMeterProgressDrawComponent,
		transform = ui.newAlignedTransform(gasMeterProgressDrawComponent, ui.align.LEFT, ui.align.BOTTOM, padding, -padding)
	}

	local packageContainerQuad = love.graphics.newQuad(
		32, 54,
		packageContainerWidth, packageContainerHeight,
		uiImage
	)
	local packageContainerDrawComponent = draw.new(uiImage, packageContainerQuad)
	packageContainer = {
		drawComponent = packageContainerDrawComponent,
		transform = ui.newAlignedTransform(packageContainerDrawComponent, ui.align.RIGHT, ui.align.BOTTOM, -padding, -padding)
	}
end

function ui.draw(gasRemaining, packages)
	love.graphics.setShader()

	draw.draw(gasMeter.drawComponent, gasMeter.transform)
	local _, _, gasMeterWidth, gasMeterHeight = gasMeter.drawComponent.quad:getViewport()
	-- love.graphics.draw(ui.image, ui.gasMeterQuad, padding, settings.canvasPixelHeight - gasMeterHeight - padding)
	-- love.graphics.setShader(ui.gasMeterShader)
	local gasMeterY = settings.canvasPixelHeight - gasMeterHeight - padding
	-- love.graphics.draw(ui.image, ui.gasMeterProgressQuad, padding, gasMeterY)
	draw.draw(gasMeterProgress.drawComponent, gasMeterProgress.transform)

	love.graphics.setShader()
	love.graphics.print(math.floor(gasRemaining), padding, gasMeterY - padding * 2)

	draw.draw(packageContainer.drawComponent, packageContainer.transform)
	local packageOffsetY = packageOffsetYInitial
	packageEffect.setShader(nil)
	for _, package in ipairs(packages) do
		love.graphics.draw(
			package.drawComponent.image,
			package.drawComponent.quad,
			packageUiLocation.x + packageOffsetXInitial,
			packageUiLocation.y + packageOffsetY
		)
		packageOffsetY = packageOffsetY + packageUiVerticalSpacing
	end
	love.graphics.setShader()
end

return ui
