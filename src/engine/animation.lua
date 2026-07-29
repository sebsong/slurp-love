local Animation = {}

local Sprite = require("engine/sprite")

function Animation.new(image, numFrames, duration, isLooping, xOffset, yOffset, zIndex, zIndexOffset)
	local quads = {}
	local imageWidth, imageHeight = image:getDimensions()
	local quadWidth, quadHeight = imageWidth / numFrames, imageHeight
	for i = 0, numFrames - 1 do
		table.insert(quads, love.graphics.newQuad(i * quadWidth, 0, quadWidth, quadHeight, image))
	end

	local sprite = Sprite.new(image, quads, xOffset, yOffset, zIndex, zIndexOffset)

	-- TODO: organize these in a separate section
	sprite.isPlaying = false
	sprite.isReversed = false
	sprite.isLooping = isLooping
	sprite.numFrames = numFrames
	sprite.currentFrame = 1
	sprite.frameDurationSeconds = (duration or 0) / numFrames
	sprite.currentFrameSeconds = 0
	sprite.onFinish = nil

	return sprite
end

local function reset(anim)
	if not anim.isReversed then
		anim.currentFrame = 1
	else
		anim.currentFrame = anim.numFrames
	end
	anim.currentFrameSeconds = 0
end

function Animation.play(anim, isReversed, onFinish)
	anim.isReversed = isReversed
	reset(anim)
	anim.onFinish = onFinish
	anim.isPlaying = true
end

local function isFinalFrame(anim)
	if not anim.isReversed then
		return anim.currentFrame == anim.numFrames
	else
		return anim.currentFrame == 1
	end
end

local function incrementFrame(anim)
	if not anim.isReversed then
		anim.currentFrame = anim.currentFrame + 1
	else
		anim.currentFrame = anim.currentFrame - 1
	end
	anim.currentFrameSeconds = 0
end

local function nextFrame(anim)
	if not isFinalFrame(anim) then
		incrementFrame(anim)
	else
		if anim.onFinish then
			anim.onFinish()
		end
		if anim.isLooping then
			reset(anim)
		else
			Animation.stop(anim)
		end
	end
end

function Animation.update(anim, dt)
	if not anim.isPlaying then
		return
	end

	if anim.currentFrameSeconds >= anim.frameDurationSeconds then
		nextFrame(anim)
	end

	anim.currentFrameSeconds = anim.currentFrameSeconds + dt
end

function Animation.stop(anim)
	anim.isPlaying = false
end

return Animation
