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
	local gasMeterSprite = Sprite.new(uiImage, gasMeterQuad)
	gasMeter = {
		sprite = gasMeterSprite,
		transform = Ui.newAlignedTransform(gasMeterSprite.width, gasMeterSprite.height, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	local gasMeterProgressQuad = love.graphics.newQuad(
		gasMeterWidth, 0,
		gasMeterWidth, gasMeterHeight,
		uiImage
	)
	GameUi.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
	GameUi.gasMeterShader:send("progress", 1.0)
	local gasMeterProgressSprite = Sprite.new(uiImage, gasMeterProgressQuad)
	gasMeterProgressSprite.setShader = function() love.graphics.setShader(GameUi.gasMeterShader) end
	gasMeterProgress = {
		sprite = gasMeterProgressSprite,
		transform = Ui.newAlignedTransform(gasMeterProgressSprite.width, gasMeterProgressSprite.height, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	local packageContainerQuad = love.graphics.newQuad(
		32, 36,
		packageContainerWidth, packageContainerHeight,
		uiImage
	)
	local packageContainerSprite = Sprite.new(uiImage, packageContainerQuad)
	packageContainer = {
		sprite = packageContainerSprite,
		transform = Ui.newAlignedTransform(packageContainerSprite.width, packageContainerSprite.height, Ui.align.RIGHT, Ui.align.BOTTOM, GameUi.PADDING, GameUi.PADDING)
	}

	gasRemainingTextTransform = Ui.newAlignedTransform(GAS_TEXT_WIDTH, GAS_TEXT_HEIGHT, Ui.align.LEFT, Ui.align.BOTTOM, GameUi.PADDING, gasMeterHeight + GameUi.PADDING * 2)
end

function GameUi.draw(gasRemaining, packages)
	love.graphics.setShader()

	Sprite.draw(gasMeter.sprite, gasMeter.transform)
	Sprite.draw(gasMeterProgress.sprite, gasMeterProgress.transform)

	love.graphics.setShader()
	love.graphics.printf(math.floor(gasRemaining), gasRemainingTextTransform, GAS_TEXT_WIDTH, "center")

	Sprite.draw(packageContainer.sprite, packageContainer.transform)
	local packageOffsetY = packageOffsetYInitial
	PackageEffect.setShader(nil)
	local x, y = packageContainer.transform:transformPoint(0, 0)
	for _, package in ipairs(packages) do
		love.graphics.draw(
			package.sprite.image,
			package.sprite.quad,
			x + packageOffsetXInitial,
			y + packageOffsetY
		)
		packageOffsetY = packageOffsetY + packageUiVerticalSpacing
	end
	love.graphics.setShader()
end

return GameUi
