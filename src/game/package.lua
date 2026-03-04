-- package types
local BASIC = 1
local RADIOACTIVE_JUNK = 2
local LANTERN = 3
local LEAD_FOOT = 4

local function applyEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed * 2
		boat.rotationSpeed = boat.rotationSpeed * 2
	elseif tileId == LANTERN then
		boat.isLanternActive = true
	elseif tileId == LEAD_FOOT then
		boat.deceleration = 0
		boat.gasDepletionRate = boat.gasDepletionRate / 2
	end
end

local function removeEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed / 2
		boat.rotationSpeed = boat.rotationSpeed / 2
	elseif tileId == LANTERN then
		boat.isLanternActive = false
	elseif tileId == LEAD_FOOT then
		boat.deceleration = BOAT_DECELERATION_DEFAULT
		boat.gasDepletionRate = boat.gasDepletionRate * 2
	end
end

function ConvertToPackage(tileObject)
	tileObject.destinationId = tileObject.properties.destination.id
	tileObject.applyEffect = applyEffect
	tileObject.removeEffect = removeEffect
	return tileObject
end
