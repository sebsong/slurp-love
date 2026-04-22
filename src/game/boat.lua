local boat = {}

local slurp_math = require("engine/math")
local collision = require("engine/collision")
local animation = require("engine/animation")

local values = require("game/values")
local ui = require("game/ui")

local NUM_BOAT_ANGLES = 16
local BOAT_WIDTH, BOATH_HEIGHT = 16, 16

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
		ui.gasMeterShader:send("progress", self.gas / values.INITIAL_GAS)
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

	local rotSegmentLength = 2 * math.pi / #self.drawComponent.quads
	local frameIdx = math.floor(
		(
			((self.rotation + (rotSegmentLength / 2)) % (2 * math.pi)) /
			(rotSegmentLength)
		)
	) + 1
	self.drawComponent.currentFrame = frameIdx

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

local function draw(animation, transform)
	love.graphics.push()
	local boatX, boatY = transform:transformPoint(0, 0)
	love.graphics.draw(
		animation.image,
		animation.quads[animation.currentFrame],
		boatX + animation.xOffset,
		boatY + animation.yOffset
	)
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
			package.drawComponent.shouldDraw = false
			package:applyEffect(self)
		end

		::continue::
	end
	return pickedUp
end

local function deliverPackage(self, mailboxes)
	if #self.packages == 0 then
		return false
	end

	local boatX, boatY = self.transform:transformPoint(0, 0)
	local package = self.packages[#self.packages]

	for _, mailbox in ipairs(mailboxes) do
		local mailboxX, mailboxY = mailbox.transform:transformPoint(0, 0)
		if slurp_math.distance({ x = boatX, y = boatY }, { x = mailboxX, y = mailboxY }) <= self.interactionRadius and
			mailbox.id == package.destinationId then
			table.remove(self.packages, #self.packages)
			package:removeEffect(self)
			package.isDelivered = true
			return true
		end
	end

	return false
end

local function getPosition(self)
	return { self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)) }
end

function boat.new(tilemap)
	local boatImage = love.graphics.newImage("assets/art/boat.png")
	local boatQuads = {}
	for i = 0, NUM_BOAT_ANGLES - 1 do
		local boatQuad = love.graphics.newQuad(
			i * BOAT_WIDTH, 0,
			BOAT_WIDTH, BOATH_HEIGHT,
			boatImage
		)
		table.insert(boatQuads, boatQuad)
	end
	local quad = boatQuads[1]
	local _, _, width, height = quad:getViewport()

	local animation = animation.new(boatImage, NUM_BOAT_ANGLES, -width / 2, -height + (8 / 2))
	animation.draw = draw

	return {
		-- TODO: build the boat from a tile object
		drawComponent = animation,
		transform = love.math.newTransform(0, -100),

		getPosition = getPosition,
		collider = { width = 1, height = 1 },

		speed = 0,
		maxSpeed = values.BOAT_MAX_SPEED_DEFAULT,
		maxBackwardsSpeed = values.BOAT_MAX_BACKWARD_SPEED_DEFAULT,
		acceleration = values.BOAT_ACCELERATION_DEFAULT,
		deceleration = values.BOAT_DECELERATION_DEFAULT,
		rotation = 0,
		rotationSpeed = math.pi / 2,
		interactionRadius = 75,
		packages = {},
		gas = values.INITIAL_GAS,
		gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT,

		isLanternActive = false,
		tilemap = tilemap,

		update = update,
		indexOfPackage = indexOfPackage,
		pickupPackages = pickupPackages,
		deliverPackage = deliverPackage,
	}
end

return boat
