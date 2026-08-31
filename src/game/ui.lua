local Align = require("engine.ui.align")
local Sprite = require("engine.sprite")
local Vec2 = require("engine.vec2")

local PackageEffect = require("game.effects.package_effect")

local GameUi = {
    PADDING = 8,
    BUTTON_DIMENSIONS = Vec2.new(128, 64), -- TODO: maybe have a better way to align ui items
}

local packageContainerWidth, packageContainerHeight = 22, 102
local packageUiVerticalSpacing = -20
local packageOffsetXInitial = 3
local packageOffsetYInitial = packageContainerHeight - 19

local gasMeter
local gasMeterProgress
local packageContainer

function GameUi.load()
    local gasProgressImage = love.graphics.newImage("assets/art/gas_progress_bar.png")
    local gasMeterSprite = Sprite.newTiled(gasProgressImage, 2, 1)
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

    GameUi.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.glsl")
    GameUi.gasMeterShader:send("progress", 1.0)
    local gasMeterProgressSprite = Sprite.newTiled(gasProgressImage, 2, 2)
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

    local packageInventoryImage = love.graphics.newImage("assets/art/package_inventory.png")
    local packageContainerSprite = Sprite.new(packageInventoryImage)
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
        love.graphics.draw(
            package.sprite.image,
            package.sprite:getCurrentQuad(),
            x + packageOffsetXInitial,
            y + packageOffsetY
        )
        packageOffsetY = packageOffsetY + packageUiVerticalSpacing
    end
    love.graphics.setShader()
end

return GameUi
