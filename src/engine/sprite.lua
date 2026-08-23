local Animation = require("engine.animation")

---@class Sprite
---@field shouldDraw boolean
---@field image love.Image | love.SpriteBatch
---@field quad love.Quad
---@field animations Animation[]
---@field currentAnimationState integer
---@field width integer
---@field height integer
---@field xOffset integer
---@field yOffset integer
---@field zIndex integer
---@field zIndexOffset integer
---@field isSpriteBatch boolean
---@field setShader fun()?
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

---@param image love.Image
---@param quad love.Quad?
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex number?
---@param zIndexOffset integer?
---@return Sprite
function Sprite.new(image, quad, xOffset, yOffset, zIndex, zIndexOffset)
    return new(image, quad, nil, xOffset, yOffset, zIndex, zIndexOffset, false)
end

---@param spriteBatch love.SpriteBatch
---@param quad love.Quad
---@param zIndex number?
---@param zIndexOffset integer?
---@return Sprite
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
---@param image love.Image
---@param animationStateConfigs AnimationConfig[]
---@param numDirections integer?
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex number?
---@param zIndexOffset integer?
---@return Sprite
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

---@param state integer
function Sprite:transitionAnimationState(state)
    assert(state >= 1 and state <= #self.animations, "invalid animation state")
    self:getCurrentAnimation():stop()
    self.currentAnimationState = state
    self:getCurrentAnimation():play()
end

---@param rotation integer
function Sprite:setDirection(rotation)
    self:getCurrentAnimation():setDirection(rotation)
end

---@return Animation
function Sprite:getCurrentAnimation()
    return self.animations[self.currentAnimationState]
end

---@param dt number
function Sprite:update(dt)
    self:getCurrentAnimation():update(dt)
end

---@param transform love.Transform
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
