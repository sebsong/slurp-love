local PackageDetail = {}

local Align = require("engine.ui.align")
local Scene = require("engine.scene")
local Sprite = require("engine.sprite")

local Font = require("game.font")
local Values = require("game.values")

local FLAVOR_TEXTS = {
    "fragile, handle with care",
    "pedal to the metal",
    "see that which is unseen",
    "caution, radioctive materials",
    "uno reverse",
}

local OPEN_STATE = 1
local CLOSE_STATE = 2

local isOpen
local shouldStop

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
    Sprite.transitionAnimationState(detailBox.sprite, CLOSE_STATE)
end

function PackageDetail.load()
    isOpen = false
    shouldStop = false

    local detailBoxImage = love.graphics.newImage("assets/art/package_detail_box.png")
    local detailBoxSprite = Sprite.newAnimated(detailBoxImage, {
        [OPEN_STATE] = {
            numFrames = 6,
            duration = 0.15,
            isLooping = false,
            isReversed = false,
            onFinish = function()
                isOpen = true
            end,
        },
        [CLOSE_STATE] = {
            numFrames = 6,
            duration = 0.15,
            isLooping = false,
            isReversed = false,
            onFinish = function()
                shouldStop = true
            end,
        },
    })
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
    local packageDetailSprite = Sprite.newAnimated(packageDetailsImage, {
        [Values.PACKAGE_TYPES.GLASS] = {},
        [Values.PACKAGE_TYPES.LEAD_FOOT] = {},
        [Values.PACKAGE_TYPES.LANTERN] = {},
        [Values.PACKAGE_TYPES.RADIOACTIVE_JUNK] = {},
        [Values.PACKAGE_TYPES.MIRROR] = {},
    })
    Sprite.transitionAnimationState(packageDetailSprite, packageIndex or 1)
    packageDetailPortrait = {
        sprite = packageDetailSprite,
        transform = Align.screenAlignedTransform(
            packageDetailSprite.width,
            packageDetailSprite.height,
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
    if shouldStop then
        if onClose then
            onClose()
        end
        Scene.stop(Scene.scenes.packageDetail)
    end

    Sprite.update(detailBox.sprite, dt)
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
