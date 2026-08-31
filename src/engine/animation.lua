---@class Animation
---@field private quads love.Quad[][] [directions][frames] -- TODO: this is really a shared resource, all animation instances would share this
---@field private isPlaying boolean
---@field private isReversed boolean
---@field private isLooping boolean
---@field private numFrames integer
---@field private frameDurationSeconds number
---@field private currentDirection integer
---@field private currentFrame integer
---@field private currentFrameSeconds number
---@field private onFinish fun()?
local Animation = {}
Animation.__index = Animation

---@class AnimationConfig
---@field numFrames integer?
---@field duration number?
---@field isLooping boolean?
---@field isReversed boolean?
---@field onFinish fun()?

---@param image love.Image
---@param quadWidth integer
---@param quadHeight integer
---@param rowIndex number
---@param numDirections integer
---@param config AnimationConfig
---@return Animation
function Animation.new(image, quadWidth, quadHeight, rowIndex, numDirections, config)
    local numFrames = config.numFrames or 1
    local duration = config.duration or 0
    local isLooping = config.isLooping or false
    local isReversed = config.isReversed or false
    local onFinish = config.onFinish or false

    local frameWidth = quadWidth * numDirections
    local y = rowIndex * quadHeight

    local quads = {}
    for i = 0, numDirections - 1 do
        local directionQuads = {}
        for j = 0, numFrames - 1 do
            local x = (j * frameWidth) + (i * quadWidth)
            table.insert(directionQuads, love.graphics.newQuad(x, y, quadWidth, quadHeight, image))
        end
        table.insert(quads, directionQuads)
    end

    local animation = {
        quads = quads,

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

---@return love.Quad
function Animation:getCurrentQuad()
    return self.quads[self.currentDirection][self.currentFrame]
end

---@param rotation integer
function Animation:setDirection(rotation)
    local rotSegmentLength = 2 * math.pi / #self.quads
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

---@param dt number
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
