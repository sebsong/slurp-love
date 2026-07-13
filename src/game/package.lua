local package = {
	type = {
		BASIC = 1,
		RADIOACTIVE_JUNK = 2,
		LANTERN = 3,
		LEAD_FOOT = 4,
		FUEL_CELL = 5,
		GLASS = 6,
		MIRROR = 7,
	}
}
local meta = {}
meta.__index = meta

local values = require("game/values")

local crack1Sound
local crack2Sound
local crackSounds
local shatterSound

local function reversePackageOrder(boat)
	local numPackages = #boat.packages
	for i = 1, math.floor(numPackages / 2) do
		boat.packages[i], boat.packages[numPackages + 1 - i] = boat.packages[numPackages + 1 - i], boat.packages[i]
	end
end

function meta:onPickup(boat)
	local tileId = self.tileId
	if tileId == package.type.BASIC then
	elseif tileId == package.type.RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed * 2
	elseif tileId == package.type.LANTERN then
		boat.isLanternActive = true
	elseif tileId == package.type.LEAD_FOOT then
		boat.autoAccelerate = true
	elseif tileId == package.type.FUEL_CELL then
		boat.gasDepletionRate = 0
		self.gasRemaining = values.FUEL_CELL_INITIAL_GAS
		self.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	elseif tileId == package.type.GLASS then
		self.cracksRemaining = 3
	elseif tileId == package.type.MIRROR then
		reversePackageOrder(boat)
	end
end

function meta:onDeliver(boat)
	local tileId = self.tileId
	if tileId == package.type.BASIC then
	elseif tileId == package.type.RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed / 2
	elseif tileId == package.type.LANTERN then
		boat.isLanternActive = false
	elseif tileId == package.type.LEAD_FOOT then
		boat.autoAccelerate = false
	elseif tileId == package.type.FUEL_CELL then
		boat.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	elseif tileId == package.type.MIRROR then
		reversePackageOrder(boat)
	end
end

function meta:onCollision(boat, _collidable)
	if self.tileId == package.type.GLASS then
		if not self.canDeliver then
			return
		end

		if boat.collidingWith:isEmpty() then
			self.cracksRemaining = self.cracksRemaining - 1
			if self.cracksRemaining > 0 then
				crackSounds[self.cracksRemaining]:play()
			else
				shatterSound:play()
				self.canDeliver = false
			end
		end
	end
end

function meta:update(dt)
	if self.tileId == package.type.FUEL_CELL then
		if self.gasRemaining >= 0 then
			self.gasRemaining = self.gasRemaining - self.gasDepletionRate * dt
			if self.gasRemaining < 0 then
				print("explode")
			end
		end
	end
end

function package.load()
	crack1Sound = love.audio.newSource("assets/sound/crack_1.ogg", "static")
	crack1Sound:setVolume(0.5)
	crack2Sound = love.audio.newSource("assets/sound/crack_2.ogg", "static")
	crack2Sound:setVolume(0.5)
	crackSounds = { crack2Sound, crack1Sound }
	shatterSound = love.audio.newSource("assets/sound/shatter.ogg", "static")
	shatterSound:setVolume(0.5)
end

function package.toPackage(tileObject)
	setmetatable(tileObject, meta)
	tileObject.destinationId = tileObject.properties.destination.id
	tileObject.isDelivered = false
	tileObject.canDeliver = true
	return tileObject
end

return package
