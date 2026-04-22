local package = {}

local values = require("game/values")

-- package types
local BASIC = 1
local RADIOACTIVE_JUNK = 2
local LANTERN = 3
local LEAD_FOOT = 4
local FUEL_CELL = 5

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
	elseif tileId == FUEL_CELL then
		boat.gasDepletionRate = 0
		self.meta.gas = values.FUEL_CELL_INITIAL_GAS
		self.meta.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
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
		boat.deceleration = values.BOAT_DECELERATION_DEFAULT
		boat.gasDepletionRate = boat.gasDepletionRate * 2
	elseif tileId == FUEL_CELL then
		boat.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	end
end

local function update(self, dt)
	if self.tileId == FUEL_CELL then
		if self.meta.gas >= 0 then
			self.meta.gas = self.meta.gas - self.meta.gasDepletionRate * dt
			if self.meta.gas < 0 then
				print("explode")
			end
		end
	end
end

function package.toPackage(tileObject)
	tileObject.destinationId = tileObject.properties.destination.id
	tileObject.applyEffect = applyEffect
	tileObject.removeEffect = removeEffect
	tileObject.update = update
	tileObject.isDelivered = false
	tileObject.meta = {}
	return tileObject
end

return package
