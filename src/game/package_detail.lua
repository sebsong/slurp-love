local PackageDetail = {}

local Align = require("engine.ui.align")
local Animation = require("engine.animation")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local FLAVOR_TEXTS = {
    "fragile, handle with care",
    "pedal to the metal",
    "see that which is unseen",
    "caution, radioctive materials",
    "uno reverse",
}

local isOpen
local shouldClose

local detailBox
local packageDetailPortrait

local textTransform
local textWidth
local textHeight

local packageIndex
local onClose

function PackageDetail.open(_packageIndex, _onClose)
    packageIndex = _packageIndex
    onClose = _onClose
    Scene.start(Scene.scenes.packageDetail)
end

function PackageDetail.close()
    isOpen = false
    Animation.play(detailBox.sprite.animation, true, function()
        shouldClose = true
    end)
end

function PackageDetail.load()
    isOpen = false
    shouldClose = false

    local detailBoxImage = love.graphics.newImage("assets/art/package_detail_box.png")
    -- local detailBoxSprite = Sprite.new(detailBoxImage)
    local detailBoxSprite = Sprite.newAnimated(detailBoxImage, 6, 0.15)
    Animation.play(detailBoxSprite.animation, false, function()
        isOpen = true
    end)
    detailBox = {
        sprite = detailBoxSprite,
        transform = Align.screenAlignedTransform(
            detailBoxSprite.width,
            detailBoxSprite.height,
            Align.CENTER,
            Align.CENTER
        ),
    }

    local packageDetailsImage = love.graphics.newImage("assets/art/package_details.png")
    local packageDetailAnimation = Sprite.newAnimated(packageDetailsImage, 5)
    packageDetailAnimation.animation.currentFrame = packageIndex or 1
    packageDetailPortrait = {
        sprite = packageDetailAnimation,
        transform = Align.screenAlignedTransform(
            packageDetailAnimation.width,
            packageDetailAnimation.height,
            Align.CENTER,
            Align.CENTER,
            0,
            -50
        ),
    }

    textWidth = 420
    textHeight = 105
    textTransform = Align.screenAlignedTransform(textWidth, textHeight, Align.CENTER, Align.BOTTOM)
end

function PackageDetail.unload() end

function PackageDetail.onPause() end

function PackageDetail.onResume() end

function PackageDetail.keypressed(key, scancode, isRepeat)
    if key == "space" then
        PackageDetail.close()
    end
end

function PackageDetail.mousepressed(x, y, button, isTouch, presses) end

function PackageDetail.mousemoved(x, y, dx, dy, isTouch) end

function PackageDetail.wheelmoved(x, y) end

function PackageDetail.update(dt)
    if shouldClose then
        if onClose then
            onClose()
        end
        Scene.stop(Scene.scenes.packageDetail)
    end

    Animation.update(detailBox.sprite.animation, dt)
end

function PackageDetail.draw()
    love.graphics.push()

    love.graphics.setShader()
    Sprite.draw(detailBox.sprite, detailBox.transform)

    if not isOpen then
        love.graphics.pop()
        return
    end

    Sprite.draw(packageDetailPortrait.sprite, packageDetailPortrait.transform)

    love.graphics.setFont(Font.medium)
    love.graphics.printf(FLAVOR_TEXTS[packageIndex], textTransform, textWidth, "center")

    love.graphics.pop()
end

return PackageDetail
