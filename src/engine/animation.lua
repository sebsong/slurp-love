---@class Animation
---@field directions love.Quad[][]
---@field isPlaying boolean
---@field isReversed boolean
---@field isLooping boolean
---@field numFrames number
---@field frameDurationSeconds number
---@field currentDirection number
---@field currentFrame number
---@field currentFrameSeconds number
---@field onFinish fun()?
---@field new fun(image: love.Image, referenceQuad: love.Quad, rowIndex: number, numDirections: number, config: AnimationConfig): Animation
---@
---@field getCurrentQuad fun(self: Animation): love.Quad
---@field setDirection fun(self: Animation, rotation: number)
---@field play fun(self: Animation)
---@field update fun(self: Animation, dt: number)
---@field stop fun(self: Animation)
local Animation = {}
Animation.__index = Animation

---@class AnimationConfig
---@field numFrames number?
---@field duration number?
---@field isLooping boolean?
---@field isReversed boolean?
---@field onFinish fun()?

function Animation.new(image, referenceQuad, rowIndex, numDirections, config)
    local numFrames = config.numFrames or 1
    local duration = config.duration or 0
    local isLooping = config.isLooping or false
    local isReversed = config.isReversed or false
    local onFinish = config.onFinish or false

    local _, _, quadWidth, quadHeight = referenceQuad:getViewport()
    local frameWidth = quadWidth * numDirections
    local y = rowIndex * quadHeight

    local directions = {}
    for i = 0, numDirections - 1 do
        local quads = {}
        for j = 0, numFrames - 1 do
            local x = (j * frameWidth) + (i * quadWidth)
            table.insert(quads, love.graphics.newQuad(x, y, quadWidth, quadHeight, image))
        end
        table.insert(directions, quads)
    end

    local animation = {
        directions = directions,

        isPlaying = false,
        isReversed = isReversed,
        isLooping = isLooping,
        numFrames = numFrames,
        frameDurationSeconds = duration / numFrames,

        currentDirection = 1,
        currentFrame = 1,
        currentFrameSeconds = 0,
        onFinish = onFinish,
    }
    setmetatable(animation, Animation)

    return animation
end

function Animation:getCurrentQuad()
    return self.directions[self.currentDirection][self.currentFrame]
end

function Animation:setDirection(rotation)
    local rotSegmentLength = 2 * math.pi / #self.directions
    local direction = math.floor((((rotation + (rotSegmentLength / 2)) % (2 * math.pi)) / rotSegmentLength)) + 1
    self.currentDirection = direction
end

local function reset(animation)
    if not animation.isReversed then
        animation.currentFrame = 1
    else
        animation.currentFrame = animation.numFrames
    end
    animation.currentFrameSeconds = 0
end

function Animation:play()
    reset(self)
    self.isPlaying = true
end

local function isFinalFrame(animation)
    if not animation.isReversed then
        return animation.currentFrame == animation.numFrames
    else
        return animation.currentFrame == 1
    end
end

local function incrementFrame(animation)
    if not animation.isReversed then
        animation.currentFrame = animation.currentFrame + 1
    else
        animation.currentFrame = animation.currentFrame - 1
    end
    animation.currentFrameSeconds = 0
end

local function nextFrame(animation)
    if not isFinalFrame(animation) then
        incrementFrame(animation)
    else
        if animation.onFinish then
            animation.onFinish()
        end
        if animation.isLooping then
            reset(animation)
        else
            Animation.stop(animation)
        end
    end
end

function Animation:update(dt)
    if not self.isPlaying then
        return
    end

    if self.currentFrameSeconds >= self.frameDurationSeconds then
        nextFrame(self)
    end

    self.currentFrameSeconds = self.currentFrameSeconds + dt
end

function Animation:stop()
    self.isPlaying = false
end

return Animation
