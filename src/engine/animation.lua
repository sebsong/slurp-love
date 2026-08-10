local Animation = {}

function Animation.new(image, referenceQuad, rowIndex, numDirections, config)
    -- TODO: maybe these are just baked into the animation and not sent on play
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

    return {
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
end

function Animation.getCurrentQuad(animation)
    return animation.directions[animation.currentDirection][animation.currentFrame]
end

function Animation.setDirection(animation, rotation)
    local rotSegmentLength = 2 * math.pi / #animation.directions
    local direction = math.floor((((rotation + (rotSegmentLength / 2)) % (2 * math.pi)) / rotSegmentLength)) + 1
    animation.currentDirection = direction
end

local function reset(animation)
    if not animation.isReversed then
        animation.currentFrame = 1
    else
        animation.currentFrame = animation.numFrames
    end
    animation.currentFrameSeconds = 0
end

function Animation.play(animation)
    reset(animation)
    animation.isPlaying = true
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

function Animation.update(animation, dt)
    if not animation.isPlaying then
        return
    end

    if animation.currentFrameSeconds >= animation.frameDurationSeconds then
        nextFrame(animation)
    end

    animation.currentFrameSeconds = animation.currentFrameSeconds + dt
end

function Animation.stop(animation)
    animation.isPlaying = false
end

return Animation
