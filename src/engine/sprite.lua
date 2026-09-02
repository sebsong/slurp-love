local Animation = require("engine.animation")
local Render = require("engine.render")

---@class Sprite: Renderable
---@field shouldDraw boolean
---@field image love.Image | love.SpriteBatch
---@field animations Animation[]?
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

---@param image love.Image | love.SpriteBatch
---@param width integer
---@param height integer
---@param animations Animation[]?
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex integer?
---@param zIndexOffset integer?
---@param isSpriteBatch boolean
---@return Sprite
local function new(image, width, height, animations, xOffset, yOffset, zIndex, zIndexOffset, isSpriteBatch)
    ---@type Sprite
    local sprite = {
        shouldDraw = true,
        image = image,
        animations = animations,
        currentAnimationState = 1,
        width = width,
        height = height,
        xOffset = xOffset or 0,
        yOffset = yOffset or 0,
        zIndex = zIndex or 0,
        zIndexOffset = zIndexOffset or 0,
        isSpriteBatch = isSpriteBatch,

        setShader = nil,
    }
    setmetatable(sprite, Sprite)

    return sprite
end

---@param image love.Image
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex number?
---@param zIndexOffset integer?
---@return Sprite
function Sprite.new(image, xOffset, yOffset, zIndex, zIndexOffset)
    local width, height = image:getDimensions()
    return new(image, width, height, nil, xOffset, yOffset, zIndex, zIndexOffset, false)
end

--TODO: maybe sprite batches should be a separate layer on top of a sprite, not integrated
---@param spriteBatch love.SpriteBatch
---@param quadWidth integer
---@param quadHeight integer
---@param zIndex number?
---@param zIndexOffset integer?
---@return Sprite
function Sprite.newSpriteBatch(image, spriteBatch, quadWidth, quadHeight, zIndex, zIndexOffset)
    local animation = Animation.new(image, quadWidth, quadHeight, 1, 1, {})
    return new(spriteBatch, quadWidth, quadHeight, { animation }, nil, nil, zIndex, zIndexOffset, true)
end

---@param image love.Image
---@param tilesetSize integer
---@param tileId integer
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex integer?
---@param zIndexOffset integer?
---@return Sprite
function Sprite.newTiled(image, tilesetSize, tileId, xOffset, yOffset, zIndex, zIndexOffset)
    local configs = {}
    for _ = 1, tilesetSize do
        table.insert(configs, {})
    end

    local sprite = Sprite.newAnimated(image, configs, 1, xOffset, yOffset, zIndex, zIndexOffset)

    sprite.currentAnimationState = tileId

    return sprite
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
        if config.numFrames and config.numFrames > maxNumFrames then
            maxNumFrames = config.numFrames
        end
    end

    local quadWidth, quadHeight = Sprite.calculateQuadDimensions(image, numStates, numDirections, maxNumFrames or 1)

    local animations = {}
    for stateIndex, config in ipairs(animationStateConfigs) do
        local animation = Animation.new(image, quadWidth, quadHeight, stateIndex, numDirections, config)
        table.insert(animations, animation)
    end

    local sprite = new(image, quadWidth, quadHeight, animations, xOffset, yOffset, zIndex, zIndexOffset, false)

    sprite:transitionAnimationState(sprite.currentAnimationState)

    return sprite
end

---@param image love.Image
---@param numStates integer
---@param numDirections integer
---@param maxNumFrames integer
---@return integer
---@return integer
function Sprite.calculateQuadDimensions(image, numStates, numDirections, maxNumFrames)
    local imageWidth, imageHeight = image:getDimensions()
    local quadWidth = imageWidth / (numDirections * maxNumFrames)
    local quadHeight = imageHeight / numStates
    return quadWidth, quadHeight
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

---@return love.Quad
function Sprite:getCurrentQuad()
    return self:getCurrentAnimation():getCurrentQuad()
end

function Sprite:getZIndex()
    return self.zIndex + self.zIndexOffset
end

---@param dt number
function Sprite:update(dt)
    self:getCurrentAnimation():update(dt)
end

---@param sprite Sprite
local function draw(sprite)
    local quad
    if sprite.animations then
        quad = sprite:getCurrentQuad()
    end

    if not quad or sprite.isSpriteBatch then
        love.graphics.draw(sprite.image, sprite.xOffset, sprite.yOffset)
    else
        love.graphics.draw(sprite.image, quad, sprite.xOffset, sprite.yOffset)
    end
end

---@param transform love.Transform?
function Sprite:draw(transform)
    Render.draw(self, transform, draw)
end

return Sprite
