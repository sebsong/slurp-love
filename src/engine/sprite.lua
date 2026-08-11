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
        quad = quad, -- TODO: remove this in favor of storing it in animation
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

-- the expected image format is:
--     each row represents an animation state
--     each animation frame contains each direction packed horizontally
--
-- example:
-- o o o o O O O O o o o o
-- u u u u U U U U u u u u
-- 2 states (o vs u)
-- 3 frames (o vs O)
-- 4 directions
function Sprite.newAnimated(image, animationStateConfigs, numDirections, xOffset, yOffset, zIndex, zIndexOffset)
    assert(#animationStateConfigs > 0, "must provide at least 1 animation config")

    local numStates = #animationStateConfigs
    numDirections = numDirections or 1
    local maxNumFrames = 1
    for _, config in ipairs(animationStateConfigs) do
        if config.numFrames or 1 > maxNumFrames then
            maxNumFrames = config.numFrames
        end
    end

    local imageWidth, imageHeight = image:getDimensions()
    local quadWidth = imageWidth / (numDirections * maxNumFrames)
    local quadHeight = imageHeight / numStates
    local quad = love.graphics.newQuad(0, 0, quadWidth, quadHeight, image)

    local animations = {}
    for stateIndex, config in ipairs(animationStateConfigs) do
        local animation = Animation.new(image, quad, stateIndex - 1, numDirections, config)
        table.insert(animations, animation)
    end

    local sprite = new(image, quad, animations, xOffset, yOffset, zIndex, zIndexOffset, false)

    Sprite.transitionAnimationState(sprite, sprite.currentAnimationState)

    return sprite
end

function Sprite.transitionAnimationState(sprite, state)
    assert(state >= 1 and state <= #sprite.animations, "invalid animation state")
    Animation.stop(Sprite.getCurrentAnimation(sprite))
    sprite.currentAnimationState = state
    Animation.play(Sprite.getCurrentAnimation(sprite))
end

function Sprite.setDirection(sprite, rotation)
    Animation.setDirection(Sprite.getCurrentAnimation(sprite), rotation)
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
