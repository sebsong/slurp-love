local PackageDetail = {}

local Align = require("engine.ui.align")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local Values = require("game.values")

local FLAVOR_TEXTS = {
    "fragile, handle with care",
    "pedal to the metal",
    "see that which is unseen",
    "fly like the wind",
    "uno reverse",
}

local OPEN_STATE = 1
local CLOSE_STATE = 2

local isOpen
local shouldStop

local detailBox
local packageDetailPortrait

---@type TextBox
local flavorTextBox

local packageIndex
local onClose

function PackageDetail.open(_packageIndex, _onClose)
    packageIndex = _packageIndex
    onClose = _onClose
    SceneManager.scenes.packageDetail:start()
end

function PackageDetail.close()
    isOpen = false
    detailBox.sprite:transitionAnimationState(CLOSE_STATE)
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
        transform = Align.screenAlignedTransform(detailBoxSprite.width, detailBoxSprite.height, "center", "center"),
    }

    local packageDetailsImage = love.graphics.newImage("assets/art/package_details.png")
    local packageDetailSprite = Sprite.newAnimated(packageDetailsImage, {
        [Values.PACKAGE_TYPES.GLASS] = {
            numFrames = 4,
            duration = 1.5,
            isLooping = true,
            isReversed = false,
        },
        [Values.PACKAGE_TYPES.LEAD_FOOT] = {
            numFrames = 4,
            duration = 1.5,
            isLooping = true,
            isReversed = false,
        },
        [Values.PACKAGE_TYPES.LANTERN] = {
            numFrames = 4,
            duration = 1.5,
            isLooping = true,
            isReversed = false,
        },
        [Values.PACKAGE_TYPES.FEATHER] = {
            numFrames = 4,
            duration = 1.5,
            isLooping = true,
            isReversed = false,
        },
        [Values.PACKAGE_TYPES.MIRROR] = {
            numFrames = 4,
            duration = 1.5,
            isLooping = true,
            isReversed = false,
        },
    })
    packageDetailSprite:transitionAnimationState(packageIndex or 1)
    packageDetailPortrait = {
        sprite = packageDetailSprite,
        transform = Align.screenAlignedTransform(
            packageDetailSprite.width,
            packageDetailSprite.height,
            "center",
            "center",
            0,
            -50
        ),
    }

    local textHeight = 112
    local textBoxTransform = Align.alignedTransform(
        detailBox.transform,
        detailBox.sprite.width,
        detailBox.sprite.height,
        detailBox.sprite.width,
        textHeight,
        "center",
        "bottom"
    )
    flavorTextBox = TextBox.new(
        textBoxTransform,
        detailBox.sprite.width,
        textHeight,
        Font.medium,
        { Color.palette[8], FLAVOR_TEXTS[packageIndex] },
        "center",
        "center",
        "center"
    )
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
        SceneManager.scenes.packageDetail:stop()
    end

    detailBox.sprite:update(dt)
    packageDetailPortrait.sprite:update(dt)
end

function PackageDetail.draw()
    love.graphics.push()

    love.graphics.setShader()
    detailBox.sprite:draw(detailBox.transform)

    if not isOpen then
        love.graphics.pop()
        return
    end

    packageDetailPortrait.sprite:draw(packageDetailPortrait.transform)

    flavorTextBox:draw()

    love.graphics.pop()
end

return PackageDetail
