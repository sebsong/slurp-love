local boat = {}

local slurp_math = require("engine/math")
local collision = require("engine/collision")
local animation = require("engine/animation")
local vec2 = require("engine/vec2")
local set = require("engine/set")
local tilemap = require("engine/tilemap")

local values = require("game/values")
local ui = require("game/ui")
local boatEffect = require("game/boat_effect")

local NUM_BOAT_ANGLES = 16
local BOAT_WIDTH, BOATH_HEIGHT = 16, 16
local NEIGHBOR_TILE_DISTANCE = 2

local NUM_TRAIL_POSITIONS = 16

local function updateNeighborTiles(self)
	local tilemapCol, tilemapRow = self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform
		:transformPoint(0, 0))
	local tilemapColIdx = math.floor(tilemapCol)
	local tilemapRowIdx = math.floor(tilemapRow)
	self.neighborTiles = {}

	for neighborRowIdx = tilemapRowIdx - NEIGHBOR_TILE_DISTANCE, tilemapRowIdx + NEIGHBOR_TILE_DISTANCE do
		for neighborColIdx = tilemapColIdx - NEIGHBOR_TILE_DISTANCE, tilemapColIdx + NEIGHBOR_TILE_DISTANCE do
			-- TODO: better way to specify layer
			local tileRow = self.tilemap.layers["base"].tiles[neighborRowIdx]
			local tile = tileRow and tileRow[neighborColIdx]
			if tile and tile.tileId then
				if self.isLanternActive and tile.tileId == 2 then
					goto continue
				end
				table.insert(self.neighborTiles, tile)
			end
			::continue::
		end
	end
end

local function updateTrailPositions(self, dt)
	local updateAmount = math.abs(self.maxSpeed) * dt
	for i = #self.trailPositions, 1, -1 do
		local position = self.trailPositions[i]
		local target
		if i == 1 then
			target = vec2.new(self.transform:transformPoint(0, 0))
		else
			target = self.trailPositions[i - 1]
		end

		local positionDiff = target - position
		if positionDiff:magnitude() <= updateAmount then
			self.trailPositions[i] = target
		else
			local direction = positionDiff:normalized()
			self.trailPositions[i] = self.trailPositions[i] + direction * updateAmount
		end
	end
end

local function getWorldRowIdx(self)
	local colIdx, rowIdx = self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0))
	return tilemap.getWorldRowIdx(colIdx, rowIdx)
end

local function update(self, cameraObj, dt)
	local didMove = false
	local didMoveForward = false
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") or self.autoAccelerate then
		self.speed = self.speed + self.acceleration * dt
		didMove = true
		didMoveForward = true
	end
	if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and not self.autoAccelerate then
		local acceleration = self.deceleration
		if self.speed > 0 then
			acceleration = acceleration * 2
		end
		self.speed = self.speed - acceleration * dt
		didMove = true
	end

	local didAccelerate = false
	if self.speed < self.maxBackwardsSpeed or self.speed > self.maxSpeed then
		self.speed = slurp_math.clamped(self.speed, -self.maxBackwardsSpeed, self.maxSpeed)
	else
		didAccelerate = true
	end

	if didMove or self.deceleration == 0 then
		if not self.engineStartSound:isPlaying() and not self.engineLoopSound:isPlaying() then
			-- TODO: have the engine start sound play first, also fade these sounds in and out
			-- self.engineStartSound:play()
			self.engineLoopSound:play()
		end

		local depletionAmount = self.gasDepletionRate * dt
		if didAccelerate and didMoveForward then
			depletionAmount = depletionAmount * values.GAS_ACCELERATION_DEPLETION_MULTIPLIER
		end
		self.gas = self.gas - depletionAmount
		ui.gasMeterShader:send("progress", self.gas / values.INITIAL_GAS)
		if self.gas <= 0 then
			print("OUT OF GAS")
		end
	else
		self.engineStartSound:stop()
		self.engineLoopSound:stop()

		if self.speed > 0 then
			self.speed = math.max(0, self.speed - self.deceleration * dt)
		elseif self.speed < 0 then
			self.speed = math.min(0, self.speed + self.deceleration * dt)
		end
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

	self:updateNeighborTiles()
	self:updateTrailPositions(dt)

	local tilemapPosition = vec2.new(
		self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0))
	)
	local newTilemapPosition = vec2.new(
		self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, -self.speed * dt))
	)
	local tilemapPositionUpdate = newTilemapPosition - tilemapPosition
	local tileFrom = vec2.new()
	local tileTo = collision.getPositionUpdate(
		self,
		self.neighborTiles,
		tilemapPositionUpdate
	)
	local worldFrom = vec2.new(self.tilemap.tilemapIndexToWorldTransform:transformPoint(tileFrom.x, tileFrom.y))
	local worldTo = vec2.new(self.tilemap.tilemapIndexToWorldTransform:transformPoint(tileTo.x, tileTo.y))

	local boatFrom = vec2.new(self.transform:inverse():transformPoint(worldFrom.x, worldFrom.y))
	local boatTo = vec2.new(self.transform:inverse():transformPoint(worldTo.x, worldTo.y))
	local boatUpdate = boatTo - boatFrom
	self.transform:translate(boatUpdate.x, boatUpdate.y)

	self.drawComponent.zIndex = self:getWorldRowIdx()

	boatEffect.update(cameraObj)
end

local function draw(animation, transform)
	love.graphics.push()
	local boatX, boatY = transform:transformPoint(0, 0)
	boatEffect.setShader()
	love.graphics.draw(
		animation.image,
		animation.quads[animation.currentFrame],
		boatX + animation.xOffset,
		boatY + animation.yOffset
	)
	love.graphics.pop()
end

local function indexOfPackage(self, packageTileId)
	-- TODO: see if there's a lua Set or a better way to check this
	for i, boatPackage in ipairs(self.packages) do
		if boatPackage.tileId == packageTileId then -- TODO: is this comparison expensive?
			return i
		end
	end
	return nil
end

local function findPackageToPickup(self, packages)
	local closestPackage
	local closestDistance
	for _, package in ipairs(packages) do
		if self:indexOfPackage(package.tileId) then
			goto continue
		end
		local boatPos = vec2.new(self.transform:transformPoint(0, 0))
		local packagePos = vec2.new(package.transform:transformPoint(0, 0))
		local packageDistance = boatPos:distanceTo(packagePos)
		if packageDistance <= self.interactionRadius and (not closestDistance or packageDistance < closestDistance) then
			closestPackage = package
			closestDistance = packageDistance
		end

		::continue::
	end

	return closestPackage
end

local function pickupPackage(self, packages)
	local packageToPickup = self:findPackageToPickup(packages)
	if packageToPickup then
		table.insert(self.packages, packageToPickup)
		packageToPickup.drawComponent.shouldDraw = false
		packageToPickup:onPickup(self)
		return true
	end
	return false
end

local function getDeliveryMailbox(self, mailboxes)
	local boatPosition = vec2.new(self.transform:transformPoint(0, 0))
	local package = self.packages[#self.packages]

	if not package then
		return nil
	end

	for _, mailbox in ipairs(mailboxes) do
		local mailboxPosition = vec2.new(mailbox.transform:transformPoint(0, 0))
		if boatPosition:distanceTo(mailboxPosition) <= self.interactionRadius and mailbox.id == package.destinationId then
			return mailbox
		end
	end

	return nil
end

local function deliverPackage(self, mailboxes)
	if #self.packages == 0 then
		return false
	end

	local package = self.packages[#self.packages]
	local deliveryMailbox = self:getDeliveryMailbox(mailboxes)
	if deliveryMailbox then
		table.remove(self.packages, #self.packages)
		package:onDeliver(self)
		package.isDelivered = true
		return true
	end

	return false
end

local function getPosition(self)
	return vec2.new(self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)))
end

local function onCollision(self, collidable)
	if self.collidingWith:isEmpty() then
		self.bumpSound:stop()
		self.bumpSound:play()
	end
	for _, package in ipairs(self.packages) do
		package:onCollision(self, collidable)
	end
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
	animation.zIndex = 0

	boatEffect.load()

	local bumpSound = love.audio.newSource("assets/sound/bump.ogg", "static")
	local engineStartSound = love.audio.newSource("assets/sound/engine_start.ogg", "static")
	local engineLoopSound = love.audio.newSource("assets/sound/engine_loop.ogg", "static")
	engineLoopSound:setLooping(true)
	engineLoopSound:setVolume(0.25)

	local transform = love.math.newTransform(0, 300)
	local position = vec2.new(transform:transformPoint(0, 0))
	local trailPositions = {}
	for _ = 1, NUM_TRAIL_POSITIONS do
		table.insert(trailPositions, position)
	end

	return {
		-- TODO: build the boat from a tile object
		drawComponent = animation,
		transform = transform,

		bumpSound = bumpSound,
		engineStartSound = engineStartSound,
		engineLoopSound = engineLoopSound,

		getPosition = getPosition,
		onCollision = onCollision,
		collider = { width = 1, height = 1 },
		collidingWith = set.new(),

		neighborTiles = {},
		updateNeighborTiles = updateNeighborTiles,

		trailPositions = trailPositions,
		updateTrailPositions = updateTrailPositions,

		speed = 0,
		maxSpeed = values.BOAT_MAX_SPEED_DEFAULT,
		maxBackwardsSpeed = values.BOAT_MAX_BACKWARD_SPEED_DEFAULT,
		acceleration = values.BOAT_ACCELERATION_DEFAULT,
		deceleration = values.BOAT_DECELERATION_DEFAULT,
		rotation = 0,
		rotationSpeed = values.BOAT_ROTATION_SPEED_DEFAULT,
		interactionRadius = values.BOAT_INTERACTION_RADIUS,
		packages = {},
		gas = values.INITIAL_GAS,
		gasDepletionRate = values.GAS_DEPLETION_RATE_DEFAULT,

		isLanternActive = false,
		autoAccelerate = false,
		tilemap = tilemap,

		update = update,
		indexOfPackage = indexOfPackage,
		findPackageToPickup = findPackageToPickup,
		pickupPackage = pickupPackage,
		getDeliveryMailbox = getDeliveryMailbox,
		deliverPackage = deliverPackage,
		getWorldRowIdx = getWorldRowIdx
	}
end

return boat
