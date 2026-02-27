require("game/values")

local music = {}

local volume = 0.6
local chords
local drums_mellow
local drums_hype

-- TODO: audio fading can be an engine feature
local fadeSpeed = 0.01
local fadeInTargets = {}
local fadeOutTargets = {}

local function fadeIn(audioSource)
	table.insert(fadeInTargets, audioSource)
end

local function fadeOut(audioSource)
	table.insert(fadeOutTargets, audioSource)
end

local function crossFadeUpdate(fadeInTargets, fadeOutTargets, dt)
	local volumeChange = fadeSpeed * dt

	for i, audioSource in ipairs(fadeInTargets) do
		local newVolume = math.min(audioSource:getVolume() + volumeChange, volume)
		audioSource:setVolume(newVolume)
		if newVolume == volume then
			table.remove(fadeInTargets, i)
		end
	end

	for i, audioSource in ipairs(fadeOutTargets) do
		local newVolume = math.max(audioSource:getVolume() - volumeChange / 5, 0)
		audioSource:setVolume(newVolume)
		if newVolume == 0 then
			table.remove(fadeOutTargets, i)
		end
	end
end

function music:load()
	chords = love.audio.newSource("assets/sound/chords.ogg", "stream")
	chords:setVolume(volume)
	chords:setLooping(true)
	chords:play()

	drums_mellow = love.audio.newSource("assets/sound/drums_mellow.ogg", "stream")
	drums_mellow:setVolume(0)
	drums_mellow:setLooping(true)
	drums_mellow:play()

	drums_hype = love.audio.newSource("assets/sound/drums_hype.ogg", "stream")
	drums_hype:setVolume(0)
	drums_hype:setLooping(true)
	drums_hype:play()
end

function music:activateDrumsMellow()
	fadeIn(drums_mellow)
	fadeOut(drums_hype)
end

function music:activateDrumsHype()
	fadeIn(drums_hype)
	fadeOut(drums_mellow)
end

function music:deactivateDrums()
	fadeOut(drums_mellow)
	fadeOut(drums_hype)
end

function music:update(boat, dt)
	if (boat.speed > BOAT_MAX_SPEED_DEFAULT) then
		self:activateDrumsHype()
	elseif (boat.speed > BOAT_MAX_SPEED_DEFAULT / 2) then
		self:activateDrumsMellow()
	else
		self:deactivateDrums()
	end

	crossFadeUpdate(fadeInTargets, fadeOutTargets, dt)
end

return music
