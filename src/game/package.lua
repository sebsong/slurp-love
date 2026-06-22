local package = {}
local meta = {}
meta.__index = meta

local values = require("game/values")
local vec2 = require("engine/vec2")
local tilemap = require("engine/tilemap")

-- package types
local BASIC = 1
local RADIOACTIVE_JUNK = 2
local LANTERN = 3
local LEAD_FOOT = 4
local FUEL_CELL = 5
local GLASS = 6
local PORTAL = 7

local crack1Sound
local crack2Sound
local crackSounds
local shatterSound

local function swapMailboxesAndPackages(tilemapObj, mailboxes)
	for _, mailbox in ipairs(mailboxes) do
		local mailboxX, mailboxY = mailbox.transform:transformPoint(0, 0)

		mailbox.transform:setTransformation(mailbox.package.transform:transformPoint(0, 0))
		local mailboxColIdx, mailboxRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(mailbox.transform:transformPoint(0, 0))
		mailbox.drawComponent.zIndex = tilemap.getWorldRowIdx(mailboxColIdx, mailboxRowIdx)

		mailbox.package.transform:setTransformation(mailboxX, mailboxY)
		local packageColIdx, packageRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(mailbox.package.transform:transformPoint(0, 0))
		mailbox.package.drawComponent.zIndex = tilemap.getWorldRowIdx(packageColIdx, packageRowIdx)
	end
end

function meta:onPickup(boat, mailboxes)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed * 2
	elseif tileId == LANTERN then
		boat.isLanternActive = true
	elseif tileId == LEAD_FOOT then
		boat.autoAccelerate = true
	elseif tileId == FUEL_CELL then
		boat.gasDepletionRate = 0
		self.gas = values.FUEL_CELL_INITIAL_GAS
		self.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	elseif tileId == GLASS then
		self.cracksRemaining = 3
	elseif tileId == PORTAL then
		swapMailboxesAndPackages(boat.tilemap, mailboxes)
	end
end

function meta:onDeliver(boat, mailboxes)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == RADIOACTIVE_JUNK then
		boat.maxSpeed = boat.maxSpeed / 2
		-- boat.rotationSpeed = boat.rotationSpeed / 2
	elseif tileId == LANTERN then
		boat.isLanternActive = false
	elseif tileId == LEAD_FOOT then
		boat.autoAccelerate = false
	elseif tileId == FUEL_CELL then
		boat.gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT
	elseif tileId == PORTAL then
		swapMailboxesAndPackages(boat.tilemap, mailboxes)
	end
end

function meta:onCollision(boat, _collidable)
	if self.tileId == GLASS then
		if boat.collidingWith:isEmpty() then
			self.cracksRemaining = self.cracksRemaining - 1
			if self.cracksRemaining > 0 then
				crackSounds[self.cracksRemaining]:play()
			else
				shatterSound:play()
				print("BROKEN")
			end
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
	return tileObject
end

return package
