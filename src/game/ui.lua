local GameUi = {
	PADDING = 10
}

local PackageEffect = require("game/effects/package_effect")
local Sprite = require("engine/sprite")
local Ui = require("engine/ui")

local gasMeterWidth, gasMeterHeight = 16, 128
local GAS_TEXT_WIDTH = gasMeterWidth
local GAS_TEXT_HEIGHT = 12

local packageContainerWidth, packageContainerHeight = 20, 92
local packageUiVerticalSpacing = -18
local packageOffsetXInitial = 2
local packageOffsetYInitial = packageContainerHeight + packageUiVerticalSpacing

local gasMeter
local gasMeterProgress
local packageContainer
local gasRemainingTextTransform

function GameUi.load()
	local uiImage = love.graphics.newImage("assets/art/Ui.png")
	local gasMeterQuad = love.graphics.newQuad(
		0, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	local gasMeterDrawComponent = Sprite.new(uiImage, gasMeterQuad)
	gasMeter = {
		drawComponent = gasMeterDrawComponent,
		transform = Ui.newAlignedTransform(gasMeterDrawComponent.width, gasMeterDrawComponent.height, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	local gasMeterProgressQuad = love.graphics.newQuad(
		gasMeterWidth, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	GameUi.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
	GameUi.gasMeterShader:send("progress", 1.0)
	local gasMeterProgressDrawComponent = Sprite.new(uiImage, gasMeterProgressQuad)
	gasMeterProgressDrawComponent.setShader = function() love.graphics.setShader(GameUi.gasMeterShader) end
	gasMeterProgress = {
		drawComponent = gasMeterProgressDrawComponent,
		transform = Ui.newAlignedTransform(gasMeterProgressDrawComponent.width, gasMeterProgressDrawComponent.height, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	local packageContainerQuad = love.graphics.newQuad(
		32, 36,
		packageContainerWidth, packageContainerHeight,
		uiImage
	)
	local packageContainerDrawComponent = Sprite.new(uiImage, packageContainerQuad)
	packageContainer = {
		drawComponent = packageContainerDrawComponent,
		transform = Ui.newAlignedTransform(packageContainerDrawComponent.width, packageContainerDrawComponent.height, Ui.align.RIGHT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	gasRemainingTextTransform = Ui.newAlignedTransform(GAS_TEXT_WIDTH, GAS_TEXT_HEIGHT, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, gasMeterHeight + GameUi.PADDING * 2)
end

function GameUi.draw(gasRemaining, packages)
	love.graphics.setShader()

	Sprite.draw(gasMeter.drawComponent, gasMeter.transform)
	Sprite.draw(gasMeterProgress.drawComponent, gasMeterProgress.transform)

	love.graphics.setShader()
	love.graphics.printf(math.floor(gasRemaining), gasRemainingTextTransform, GAS_TEXT_WIDTH, "center")

	Sprite.draw(packageContainer.drawComponent, packageContainer.transform)
	local packageOffsetY = packageOffsetYInitial
	PackageEffect.setShader(nil)
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

return GameUi
