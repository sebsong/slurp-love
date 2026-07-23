local package = {
	type = {
		GLASS = 1,
		LEAD_FOOT = 2,
		LANTERN = 3,
		RADIOACTIVE_JUNK = 4,
		MIRROR = 5,
	}
}
local meta = {}
meta.__index = meta

local scene = require("engine/scene")

local values = require("game/values")
local packageDetail = require("game/package_detail")

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

	scene.pause(scene.scenes.game)
	packageDetail.open(tileId, function() scene.resume(scene.scenes.game) end)

	if tileId == package.type.GLASS then
		self.cracksRemaining = 3
	elseif tileId == package.type.LEAD_FOOT then
		boat.autoAccelerate = true
	elseif tileId == package.type.LANTERN then
		boat.isLanternActive = true
	elseif tileId == package.type.RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed * 2
	elseif tileId == package.type.MIRROR then
		reversePackageOrder(boat)
	end
end

function meta:onDeliver(boat)
	local tileId = self.tileId

	if tileId == package.type.GLASS then
	elseif tileId == package.type.LEAD_FOOT then
		boat.autoAccelerate = false
	elseif tileId == package.type.LANTERN then
		boat.isLanternActive = false
	elseif tileId == package.type.RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed / 2
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
