local Align = require("engine.ui.align")
local Sprite = require("engine.sprite")
local Vec2 = require("engine.vec2")

local PackageEffect = require("game.effects.package_effect")

local GameUi = {
    PADDING = 16,
    BUTTON_DIMENSIONS = Vec2.new(128, 64), -- TODO: maybe have a better way to align ui items
}

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

function GameUi.load()
    local uiImage = love.graphics.newImage("assets/art/Ui.png")
    local gasMeterQuad = love.graphics.newQuad(0, 0, gasMeterWidth, gasMeterHeight, uiImage)
    local gasMeterSprite = Sprite.new(uiImage, gasMeterQuad)
    gasMeter = {
        sprite = gasMeterSprite,
        transform = Align.screenAlignedTransform(
            gasMeterSprite.width,
            gasMeterSprite.height,
            "left",
            "bottom",
            GameUi.PADDING,
            GameUi.PADDING
        ),
    }

    local gasMeterProgressQuad = love.graphics.newQuad(gasMeterWidth, 0, gasMeterWidth, gasMeterHeight, uiImage)
    GameUi.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
    GameUi.gasMeterShader:send("progress", 1.0)
    local gasMeterProgressSprite = Sprite.new(uiImage, gasMeterProgressQuad)
    gasMeterProgressSprite.setShader = function()
        love.graphics.setShader(GameUi.gasMeterShader)
    end
    gasMeterProgress = {
        sprite = gasMeterProgressSprite,
        transform = Align.screenAlignedTransform(
            gasMeterProgressSprite.width,
            gasMeterProgressSprite.height,
            "left",
            "bottom",
            GameUi.PADDING,
            GameUi.PADDING
        ),
    }

    local packageContainerQuad = love.graphics.newQuad(32, 36, packageContainerWidth, packageContainerHeight, uiImage)
    local packageContainerSprite = Sprite.new(uiImage, packageContainerQuad)
    packageContainer = {
        sprite = packageContainerSprite,
        transform = Align.screenAlignedTransform(
            packageContainerSprite.width,
            packageContainerSprite.height,
            "right",
            "bottom",
            GameUi.PADDING,
            GameUi.PADDING
        ),
    }
end

function GameUi.draw(gasRemaining, packages)
    love.graphics.setShader()

    gasMeter.sprite:draw(gasMeter.transform)
    gasMeterProgress.sprite:draw(gasMeterProgress.transform)

    love.graphics.setShader()
    packageContainer.sprite:draw(packageContainer.transform)
    local packageOffsetY = packageOffsetYInitial
    PackageEffect.setShader(nil)
    local x, y = packageContainer.transform:transformPoint(0, 0)
    for _, package in ipairs(packages) do
        love.graphics.draw(package.sprite.image, package.sprite.quad, x + packageOffsetXInitial, y + packageOffsetY)
        packageOffsetY = packageOffsetY + packageUiVerticalSpacing
    end
    love.graphics.setShader()
end

return GameUi
