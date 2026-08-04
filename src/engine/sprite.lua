local Sprite = {}

local Animation = require("engine.animation")

function Sprite.load()
    love.graphics.setPointSize(8)
    love.graphics.setLineWidth(0.1)
    love.graphics.setBackgroundColor(0, 0, 0)
end

local function new(image, quad, animation, xOffset, yOffset, zIndex, zIndexOffset, isSpriteBatch)
    local width, height
    if quad then
        _, _, width, height = quad:getViewport()
    else
        width, height = image:getDimensions()
    end
    return {
        shouldDraw = true,
        image = image,
        quad = quad,
        animation = animation,
        width = width,
        height = height,
        xOffset = xOffset,
        yOffset = yOffset,
        zIndex = zIndex,
        zIndexOffset = zIndexOffset,
        isSpriteBatch = isSpriteBatch,

        setShader = nil,
        draw = nil,
    }
end

function Sprite.new(image, quad, xOffset, yOffset, zIndex, zIndexOffset)
    return new(image, quad, nil, xOffset, yOffset, zIndex, zIndexOffset, false)
end

function Sprite.newSpriteBatch(spriteBatch, quad, zIndex, zIndexOffset)
    return new(spriteBatch, quad, nil, nil, nil, zIndex, zIndexOffset, true)
end

function Sprite.newAnimated(image, numFrames, duration, isLooping, xOffset, yOffset, zIndex, zIndexOffset)
    local quads = {}
    local imageWidth, imageHeight = image:getDimensions()
    local quadWidth, quadHeight = imageWidth / numFrames, imageHeight
    for i = 0, numFrames - 1 do
        table.insert(quads, love.graphics.newQuad(i * quadWidth, 0, quadWidth, quadHeight, image))
    end

    local animation = Animation.new(quads, numFrames, duration, isLooping)
    local quad = Animation.getCurrentQuad(animation)

    return new(image, quad, animation, xOffset, yOffset, zIndex, zIndexOffset, false)
end

function Sprite.draw(sprite, transform)
    if not sprite.shouldDraw then
        return
    end

    if sprite.draw then
        sprite.draw(sprite, transform)
        return
    end

    love.graphics.push()
    love.graphics.applyTransform(transform)

    if sprite.setShader then
        sprite.setShader()
    else
        love.graphics.setShader()
    end

    local quad
    if sprite.animation then
        quad = Animation.getCurrentQuad(sprite.animation)
    else
        quad = sprite.quad
    end

    if quad and not sprite.isSpriteBatch then
        love.graphics.draw(sprite.image, quad, sprite.xOffset, sprite.yOffset)
    else
        love.graphics.draw(sprite.image, sprite.xOffset, sprite.yOffset)
    end
    love.graphics.pop()
end

return Sprite
