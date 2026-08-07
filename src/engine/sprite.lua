local Sprite = {}

local Animation = require("engine.animation")

function Sprite.load()
    love.graphics.setPointSize(8)
    love.graphics.setLineWidth(0.1)
    love.graphics.setBackgroundColor(0, 0, 0)
end

local function new(image, quad, animations, xOffset, yOffset, zIndex, zIndexOffset, isSpriteBatch)
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
        animations = animations,
        currentAnimationState = 1,
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
    local animation = Animation.new(image, numFrames, duration, isLooping)
    local quad = Animation.getCurrentQuad(animation)

    return new(image, quad, { animation }, xOffset, yOffset, zIndex, zIndexOffset, false)
end

-- a state with an animation associated, e.g. idle, walk, hovered, etc.
-- in the spritesheet, animation states can be stored on separate rows or separate files
function Sprite.addAnimationState(sprite, image, numFrames, duration, isLooping)
    local animation = Animation.new(image, numFrames, duration, isLooping)
    table.insert(sprite.animations, animation)
    return #sprite.animations
end

function Sprite.transitionAnimationState(sprite, state)
    assert(state >= 1 and state <= #sprite.animations, "invalid animation state")
    sprite.currentAnimationState = state
    -- TODO: play new animation
end

function Sprite.getCurrentAnimation(sprite)
    return sprite.animations[sprite.currentAnimationState]
end

function Sprite.update(sprite, dt)
    Animation.update(Sprite.getCurrentAnimation(sprite), dt)
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
    if sprite.animations then
        quad = Animation.getCurrentQuad(Sprite.getCurrentAnimation(sprite))
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
