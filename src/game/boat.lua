require("engine/math")

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

	if not didMove then
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

	local rotSegmentLength = 2 * PI / #self.quads
	local boatQuadIdx = math.floor(
		(
			((self.rotation + (rotSegmentLength / 2)) % (2 * PI)) /
			(rotSegmentLength)
		)
	) + 1
	self.currentQuad = self.quads[boatQuadIdx]

	self.transform:translate(0, -self.speed * dt)
end

local function draw(self)
	love.graphics.push()
	local boatX, boatY = self.transform:transformPoint(0, 0)
	local _, _, boatWidth, boatHeight = self.currentQuad:getViewport()
	love.graphics.draw(self.image, self.currentQuad, boatX, boatY, 0, 1, 1, boatWidth / 2, boatHeight / 2)
	love.graphics.pop()
end

function NewBoat(entitiesImage)
	local boatQuads = {}
	for i = 1, numBoatAngles do
		local boatQuad = love.graphics.newQuad(
			(6 + i - 1) * boatWidth, 2 * boatHeight,
			boatWidth, boatHeight,
			entitiesImage:getWidth(), entitiesImage:getHeight()
		)
		table.insert(boatQuads, boatQuad)
	end

	local maxSpeed = 75
	local acceleration = 2 * maxSpeed
	return {
		image = entitiesImage,
		quads = boatQuads,
		currentQuad = boatQuads[1],
		transform = love.math.newTransform(),
		speed = 0,
		maxSpeed = maxSpeed,
		maxBackwardsSpeed = maxSpeed * 0.5,
		acceleration = 2 * maxSpeed,
		deceleration = acceleration / 4,
		rotation = 0,
		rotationSpeed = PI / 4,

		update = update,
		draw = draw,
	}
end
