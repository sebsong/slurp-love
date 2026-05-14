local boat = {}

local slurp_math = require("engine/math")
local collision = require("engine/collision")
local animation = require("engine/animation")
local vec2 = require("engine/vec2")
local set = require("engine/set")
local tilemap = require("engine/tilemap")

local values = require("game/values")
local ui = require("game/ui")

local NUM_BOAT_ANGLES = 16
local BOAT_WIDTH, BOATH_HEIGHT = 16, 16
local NEIGHBOR_TILE_DISTANCE = 2

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
				-- if not tile.drawComponent then
				-- 	-- TODO: this is a temp hack
				-- 	local tilesetIndex = tile.tilesetIndex
				-- 	local tileId = tile.tileId
				-- 	if not tilesetIndex or not tileId then
				-- 		goto continue
				-- 	end
				-- 	local tileset = self.tilemap.tilesets[tilesetIndex]
				-- 	local tileQuad = tileset.quads[tileId]
				-- 	if not tileQuad then
				-- 		goto continue
				-- 	end
				-- 	local x, y = self.tilemap.tilemapIndexToWorldTransform:transformPoint(tile.position.x,
				-- 		tile.position.y)
				-- 	local _, _, width, height = tileQuad:getViewport()
				-- 	tile.drawComponent = {
				-- 		shouldDraw = true,
				-- 		image = tileset.image,
				-- 		quad = tileQuad,
				-- 		xOffset = -width / 2,
				-- 		yOffset = -height + self.tilemap.tileHeight / 2,
				-- 	}
				-- 	tile.transform = love.math.newTransform(x, y)
				-- end
				table.insert(self.neighborTiles, tile)
			end
			::continue::
		end
	end
end

local function getWorldRowIdx(self)
	local colIdx, rowIdx = self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0))
	return tilemap.getWorldRowIdx(colIdx, rowIdx)
end

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

	self:updateNeighborTiles()

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
	return vec2.new(self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)))
end

-- local tableMeta = getmetatable(table)
-- function tableMeta.__tostring(_table)
-- 	local str = ""
-- 	str = str + "{"
-- 	for key, val in pairs(_table) do
-- 		str = str + string.format("	%s: %s", key, val)
-- 	end
-- 	str = str + "}"
-- 	return str
-- end

local function onCollision(self, collidable)
	-- print(collidable.position)
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

	return {
		-- TODO: build the boat from a tile object
		drawComponent = animation,
		transform = love.math.newTransform(0, -100),

		getPosition = getPosition,
		onCollision = onCollision,
		collider = { width = 1, height = 1 },
		collidingWith = set.new(),

		neighborTiles = {},
		updateNeighborTiles = updateNeighborTiles,

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
		getWorldRowIdx = getWorldRowIdx
	}
end

return boat
