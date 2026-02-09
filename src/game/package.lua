-- package types
local BASIC = 1
local BOULDER = 2
local TENTACLE = 3

local function applyEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == BOULDER then
		boat.maxSpeed = boat.maxSpeed / 2
	elseif tileId == TENTACLE then
	end
end

local function removeEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == BOULDER then
		boat.maxSpeed = boat.maxSpeed * 2
	elseif tileId == TENTACLE then
	end
end

function ConvertToPackage(tileObject)
	tileObject.destinationId = tileObject.properties.destination.id
	tileObject.applyEffect = applyEffect
	tileObject.removeEffect = removeEffect
	return tileObject
end
