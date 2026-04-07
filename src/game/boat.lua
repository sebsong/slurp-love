local slurp_math = require("engine/math")
require("engine/color")
local collision = require("engine/collision")

require("game/values")
local ui = require("game/ui")

local numBoatAngles = 16
local boatWidth, boatHeight = 16, 16

local function update(self, dt)
	local didMove = false
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
		self.speed = self.speed + self.acceleration * dt
		didMove = true
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		local acceleration = self.deceleration
		if self.speed > 0 then
			acceleration = acceleration * 2
		end
		self.speed = self.speed - acceleration * dt
		didMove = true
	end

	if didMove then
		self.gas = self.gas - self.gasDepletionRate * dt
		ui.gasMeterShader:send("progress", self.gas / INITIAL_GAS)
		if self.gas <= 0 then
			print("OUT OF GAS")
		end
	else
		if self.speed > 0 then
			self.speed = math.max(0, self.speed - self.deceleration * dt)
		elseif self.speed < 0 then
			self.speed = math.min(0, self.speed + self.deceleration * dt)
		end
	end

	if self.speed > 0 and self.speed > self.maxSpeed then
		self.speed = self.maxSpeed
	elseif self.speed < 0 and self.speed < -self.maxBackwardsSpeed then
		self.speed = -self.maxBackwardsSpeed
	end

	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		self.rotation = self.rotation - self.rotationSpeed * dt
		self.transform:rotate(-self.rotationSpeed * dt)
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		self.rotation = self.rotation + self.rotationSpeed * dt
		self.transform:rotate(self.rotationSpeed * dt)
	end

	local rotSegmentLength = 2 * math.pi / #self.quads
	local boatQuadIdx = math.floor(
		(
			((self.rotation + (rotSegmentLength / 2)) % (2 * math.pi)) /
			(rotSegmentLength)
		)
	) + 1
	self.quad = self.quads[boatQuadIdx]

	local tilemapPosition = { self.tilemap.worldToTilemapIndexTransform:transformPoint(
		self.transform:transformPoint(0, 0)
	) }
	local newTilemapPosition = { self.tilemap.worldToTilemapIndexTransform:transformPoint(
		self.transform:transformPoint(0, -self.speed * dt)
	) }
	local tilemapPositionUpdate = {
		newTilemapPosition[1] - tilemapPosition[1],
		newTilemapPosition[2] - tilemapPosition[2]
	}

	local tileFrom = { 0, 0 }
	local tileTo = collision.getPositionUpdate(
		self,
		tilemapPositionUpdate
	)
	local worldFrom = { self.tilemap.tilemapIndexToWorldTransform:transformPoint(unpack(tileFrom)) }
	local worldTo = { self.tilemap.tilemapIndexToWorldTransform:transformPoint(unpack(tileTo)) }

	local boatFrom = { self.transform:inverse():transformPoint(unpack(worldFrom)) }
	local boatTo = { self.transform:inverse():transformPoint(unpack(worldTo)) }
	self.transform:translate(
		boatTo[1] - boatFrom[1],
		boatTo[2] - boatFrom[2]
	)
end

local function draw(self)
	love.graphics.push()
	local boatX, boatY = self.transform:transformPoint(0, 0)
	love.graphics.draw(self.image, self.quad, boatX + self.offsetX, boatY + self.offsetY)

	love.graphics.pop()
end

local function indexOfPackage(self, package)
	-- TODO: see if there's a lua Set or a better way to check this
	for i, boatPackage in ipairs(self.packages) do
		if package == boatPackage then -- TODO: is this comparison expensive?
			return i
		end
	end
	return nil
end

local function pickupPackages(self, packages)
	local pickedUp = false
	for _, package in ipairs(packages) do
		if self:indexOfPackage(package) then
			goto continue
		end
		local boatX, boatY = self.transform:transformPoint(0, 0)
		local packageX, packageY = package.transform:transformPoint(0, 0)
		if slurp_math.distance({ x = boatX, y = boatY }, { x = packageX, y = packageY }) <= self.interactionRadius then
			table.insert(self.packages, package)
			pickedUp = true
			package.shouldDraw = false
			package:applyEffect(self)
		end

		::continue::
	end
	return pickedUp
end

local function deliverPackage(self, mailboxes)
	if #self.packages == 0 then
		return
	end

	local boatX, boatY = self.transform:transformPoint(0, 0)
	local package = self.packages[#self.packages]

	for _, mailbox in ipairs(mailboxes) do
		local mailboxX, mailboxY = mailbox.transform:transformPoint(0, 0)
		if slurp_math.distance({ x = boatX, y = boatY }, { x = mailboxX, y = mailboxY }) <= self.interactionRadius and
			mailbox.id == package.destinationId then
			table.remove(self.packages, #self.packages)
			package:removeEffect(self)
			break
		end
	end
end

local function getPosition(self)
	return { self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)) }
end

function NewBoat(entitiesImage, tilemap)
	local boatQuads = {}
	for i = 1, numBoatAngles do
		local boatQuad = love.graphics.newQuad(
			(6 + i - 1) * boatWidth, 2 * boatHeight,
			boatWidth, boatHeight,
			entitiesImage:getWidth(), entitiesImage:getHeight()
		)
		table.insert(boatQuads, boatQuad)
	end
	local quad = boatQuads[1]
	local _, _, width, height = quad:getViewport()

	return {
		shouldDraw = true,
		image = entitiesImage,
		quad = quad,
		offsetX = -width / 2,
		offsetY = -height + (8 / 2), -- TODO: build the boat from a tile object
		transform = love.math.newTransform(0, -100),
		draw = draw,

		getPosition = getPosition,
		collider = { width = 1, height = 1 },

		quads = boatQuads,
		speed = 0,
		maxSpeed = BOAT_MAX_SPEED_DEFAULT,
		maxBackwardsSpeed = BOAT_MAX_BACKWARD_SPEED_DEFAULT,
		acceleration = BOAT_ACCELERATION_DEFAULT,
		deceleration = BOAT_DECELERATION_DEFAULT,
		rotation = 0,
		rotationSpeed = math.pi / 2,
		interactionRadius = 75,
		packages = {},
		gas = INITIAL_GAS,
		gasDepletionRate = GAS_DEPLETION_RATE_DEFAULT,

		isLanternActive = false,
		tilemap = tilemap,

		update = update,
		indexOfPackage = indexOfPackage,
		pickupPackages = pickupPackages,
		deliverPackage = deliverPackage,
	}
end
