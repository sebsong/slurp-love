local package = {}
local meta = {}
meta.__index = meta

local values = require("game/values")
local vec2 = require("engine/vec2")

-- package types
local BASIC = 1
local RADIOACTIVE_JUNK = 2
local LANTERN = 3
local LEAD_FOOT = 4
local FUEL_CELL = 5
local GLASS = 6
local PORTAL = 7

function meta:onPickup(boat)
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
		self.gas = values.FUEL_CELL_INITIAL_GAS
		self.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	end
end

function meta:onDeliver(boat)
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
	elseif tileId == PORTAL then
		if boat.portalDestination then
			boat.transform:setTransformation(boat.portalDestination.x, boat.portalDestination.y, boat.rotation)
		end
	end

	boat.portalDestination = vec2.new(boat.transform:transformPoint(0, 0))
end

function meta:onCollision(boat, _collidable)
	if self.tileId == GLASS then
		if boat.collidingWith:isEmpty() and boat.speed >= values.GLASS_BREAK_MIN_SPEED then
			print("BROKEN")
		end
	end
end

function meta:update(dt)
	if self.tileId == FUEL_CELL then
		if self.gas >= 0 then
			self.gas = self.gas - self.gasDepletionRate * dt
			if self.gas < 0 then
				print("explode")
			end
		end
	end
end

function package.toPackage(tileObject)
	tileObject.destinationId = tileObject.properties.destination.id
	setmetatable(tileObject, meta)
	tileObject.isDelivered = false
	return tileObject
end

return package
