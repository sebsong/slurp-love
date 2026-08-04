local Animation = {}

function Animation.new(quads, numFrames, duration, isLooping)
    return {
        quads = quads,

        isPlaying = false,
        isReversed = false,
        isLooping = isLooping,
        numFrames = numFrames,
        frameDurationSeconds = (duration or 0) / numFrames,

        currentFrame = 1,
        currentFrameSeconds = 0,
        onFinish = nil,
    }
end

function Animation.getCurrentQuad(animation)
    return animation.quads[animation.currentFrame]
end

local function reset(animation)
    if not animation.isReversed then
        animation.currentFrame = 1
    else
        animation.currentFrame = animation.numFrames
    end
    animation.currentFrameSeconds = 0
end

function Animation.play(animation, isReversed, onFinish)
    animation.isReversed = isReversed
    reset(animation)
    animation.onFinish = onFinish
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
