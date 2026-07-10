local game_ui = {}

local packageEffect = require("game/package_effect")
local draw = require("engine/draw")
local ui = require("engine/ui")

local gasMeterWidth, gasMeterHeight = 16, 128
local GAS_TEXT_WIDTH = gasMeterWidth
local GAS_TEXT_HEIGHT = 12

local packageContainerWidth, packageContainerHeight = 20, 92
local padding = 10
local packageUiVerticalSpacing = -18
local packageOffsetXInitial = 2
local packageOffsetYInitial = packageContainerHeight + packageUiVerticalSpacing

local gasMeter
local gasMeterProgress
local packageContainer
local gasRemainingTextTransform

function game_ui.load()
	local uiImage = love.graphics.newImage("assets/art/ui.png")
	local gasMeterQuad = love.graphics.newQuad(
		0, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	local gasMeterDrawComponent = draw.new(uiImage, gasMeterQuad)
	gasMeter = {
		drawComponent = gasMeterDrawComponent,
		transform = ui.newAlignedTransform(gasMeterDrawComponent.width, gasMeterDrawComponent.height, ui.align.LEFT, ui.align.BOTTOM, padding, -padding)
	}

	local gasMeterProgressQuad = love.graphics.newQuad(
		gasMeterWidth, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	game_ui.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
	game_ui.gasMeterShader:send("progress", 1.0)
	local gasMeterProgressDrawComponent = draw.new(uiImage, gasMeterProgressQuad)
	gasMeterProgressDrawComponent.setShader = function() love.graphics.setShader(ui.gasMeterShader) end
	gasMeterProgress = {
		drawComponent = gasMeterProgressDrawComponent,
		transform = ui.newAlignedTransform(gasMeterProgressDrawComponent.width, gasMeterProgressDrawComponent.height, ui.align.LEFT, ui.align.BOTTOM, padding, -padding)
	}

	local packageContainerQuad = love.graphics.newQuad(
		32, 36,
		packageContainerWidth, packageContainerHeight,
		uiImage
	)
	local packageContainerDrawComponent = draw.new(uiImage, packageContainerQuad)
	packageContainer = {
		drawComponent = packageContainerDrawComponent,
		transform = ui.newAlignedTransform(packageContainerDrawComponent.width, packageContainerDrawComponent.height, ui.align.RIGHT, ui.align.BOTTOM, -padding, -padding)
	}

	gasRemainingTextTransform = ui.newAlignedTransform(GAS_TEXT_WIDTH, GAS_TEXT_HEIGHT, ui.align.LEFT, ui.align.BOTTOM, padding, -gasMeterHeight - padding * 2)
end

function game_ui.draw(gasRemaining, packages)
	love.graphics.setShader()

	draw.draw(gasMeter.drawComponent, gasMeter.transform)
	draw.draw(gasMeterProgress.drawComponent, gasMeterProgress.transform)

	love.graphics.setShader()
	love.graphics.printf(math.floor(gasRemaining), gasRemainingTextTransform, GAS_TEXT_WIDTH, "center")

	draw.draw(packageContainer.drawComponent, packageContainer.transform)
	local packageOffsetY = packageOffsetYInitial
	packageEffect.setShader(nil)
	local x, y = packageContainer.transform:transformPoint(0, 0)
	for _, package in ipairs(packages) do
		love.graphics.draw(
			package.drawComponent.image,
			package.drawComponent.quad,
			x + packageOffsetXInitial,
			y + packageOffsetY
		)
		packageOffsetY = packageOffsetY + packageUiVerticalSpacing
	end
	love.graphics.setShader()
end

return game_ui
