local animation = {}

local draw = require("engine/draw")

function animation.new(image, numFrames, duration, isLooping, xOffset, yOffset, zIndex, zIndexOffset)
	local quads = {}
	local imageWidth, imageHeight = image:getDimensions()
	local quadWidth, quadHeight = imageWidth / numFrames, imageHeight
	for i = 0, numFrames - 1 do
		table.insert(quads, love.graphics.newQuad(i * quadWidth, 0, quadWidth, quadHeight, image))
	end

	local drawComponent = draw.new(image, quads, xOffset, yOffset, zIndex, zIndexOffset)

	-- TODO: organize these in a separate section
	drawComponent.isPlaying = false
	drawComponent.isReversed = false
	drawComponent.isLooping = isLooping
	drawComponent.numFrames = numFrames
	drawComponent.currentFrame = 1
	drawComponent.frameDurationSeconds = (duration or 0) / numFrames
	drawComponent.currentFrameSeconds = 0
	drawComponent.onFinish = nil

	return drawComponent
end

local function reset(_animation)
	if not _animation.isReversed then
		_animation.currentFrame = 1
	else
		_animation.currentFrame = _animation.numFrames
	end
	_animation.currentFrameSeconds = 0
end

function animation.play(_animation, isReversed, onFinish)
	_animation.isReversed = isReversed
	reset(_animation)
	_animation.onFinish = onFinish
	_animation.isPlaying = true
end

local function isFinalFrame(_animation)
	if not _animation.isReversed then
		return _animation.currentFrame == _animation.numFrames
	else
		return _animation.currentFrame == 1
	end
end

local function incrementFrame(_animation)
	if not _animation.isReversed then
		_animation.currentFrame = _animation.currentFrame + 1
	else
		_animation.currentFrame = _animation.currentFrame - 1
	end
	_animation.currentFrameSeconds = 0
end

local function nextFrame(_animation)
	if not isFinalFrame(_animation) then
		incrementFrame(_animation)
	else
		if _animation.onFinish then
			_animation.onFinish()
		end
		if _animation.isLooping then
			reset(_animation)
		else
			animation.stop(_animation)
		end
	end
end

function animation.update(_animation, dt)
	if not _animation.isPlaying then
		return
	end

	if _animation.currentFrameSeconds >= _animation.frameDurationSeconds then
		nextFrame(_animation)
	end

	_animation.currentFrameSeconds = _animation.currentFrameSeconds + dt
end

function animation.stop(_animation)
	_animation.isPlaying = false
end

return animation
