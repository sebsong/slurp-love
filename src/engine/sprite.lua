local Animation = require("engine.animation")

---@class Sprite
---@field shouldDraw boolean
---@field image love.Image | love.SpriteBatch
---@field quad love.Quad
---@field animations Animation[]
---@field currentAnimationState number
---@field width number
---@field height number
---@field xOffset number
---@field yOffset number
---@field zIndex number
---@field zIndexOffset number
---@field isSpriteBatch boolean
---@field setShader fun()?
---@field draw fun()?
---
---@field new fun(image: love.Image, quad: love.Quad?, xOffset: number?, yOffset: number?, zIndex: number?, zIndexOffset :number?): Sprite
---@field newSpriteBatch fun(spriteBatch: love.SpriteBatch, quad: love.Quad, zIndex: number?, zIndexOffset :number?): Sprite
---@field newAnimated fun(image: love.Image, animationStateConfigs: AnimationConfig[], numDirections: number?, xOffset: number?, yOffset: number?, zIndex: number?, zIndexOffset :number?): Sprite
---
---@field transitionAnimationState fun(self: Sprite, state: number)
---@field setDirection fun(self: Sprite, rotation: number)
---@field getCurrentAnimation fun(self: Sprite):Animation
---@field update fun(self: Sprite, dt: number)
---@field draw fun(self: Sprite, transform: love.Transform)
local Sprite = {}
Sprite.__index = Sprite

local function new(image, quad, animations, xOffset, yOffset, zIndex, zIndexOffset, isSpriteBatch)
    local width, height
    if quad then
        _, _, width, height = quad:getViewport()
    else
        width, height = image:getDimensions()
    end

    local sprite = {
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
    }
    setmetatable(sprite, Sprite)

    return sprite
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

    sprite:transitionAnimationState(sprite.currentAnimationState)

    return sprite
end

function Sprite:transitionAnimationState(state)
    assert(state >= 1 and state <= #self.animations, "invalid animation state")
    self:getCurrentAnimation():stop()
    self.currentAnimationState = state
    self:getCurrentAnimation():play()
end

function Sprite:setDirection(rotation)
    self:getCurrentAnimation():setDirection(rotation)
end

function Sprite:getCurrentAnimation()
    return self.animations[self.currentAnimationState]
end

function Sprite:update(dt)
    self:getCurrentAnimation():update(dt)
end

function Sprite:draw(transform)
    if not self.shouldDraw then
        return
    end

    love.graphics.push()
    love.graphics.applyTransform(transform)

    if self.setShader then
        self.setShader()
    else
        love.graphics.setShader()
    end

    local quad
    if self.animations then
        quad = self:getCurrentAnimation():getCurrentQuad()
    else
        quad = self.quad
    end

    if quad and not self.isSpriteBatch then
        love.graphics.draw(self.image, quad, self.xOffset, self.yOffset)
    else
        love.graphics.draw(self.image, self.xOffset, self.yOffset)
    end
    love.graphics.pop()
end

return Sprite
