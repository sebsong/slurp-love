local Boat = {}

local Animation = require("engine.animation")
local Collision = require("engine.collision")
local Math = require("engine.math")
local Set = require("engine.set")
local Sprite = require("engine.sprite")
local Tilemap = require("engine.tilemap")
local Vec2 = require("engine.vec2")

local BoatEffect = require("game.effects.boat_effect")
local GameUi = require("game.ui")
local Values = require("game.values")

local NUM_BOAT_ANGLES = 16
local BOAT_WIDTH, BOAT_HEIGHT = 16, 16
local NEIGHBOR_TILE_DISTANCE = 2

local NUM_TRAIL_POSITIONS = 16

local function updateNeighborTiles(self)
    local tilemapCol, tilemapRow =
        self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0))
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
            target = Vec2.new(self.transform:transformPoint(0, 0))
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
    return Tilemap.getWorldRowIdx(colIdx, rowIdx)
end

local function update(self, cameraObj, dt)
    local didMove = false
    local didMoveForward = false
    local didAccelerate = false

    if self.gasRemaining > 0 then
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

        if self.speed < self.maxBackwardsSpeed or self.speed > self.maxSpeed then
            self.speed = Math.clamped(self.speed, -self.maxBackwardsSpeed, self.maxSpeed)
        else
            didAccelerate = true
        end
    end

    if didMove or self.deceleration == 0 then
        if not self.engineStartSound:isPlaying() and not self.engineLoopSound:isPlaying() then
            -- TODO: have the engine start sound play first, also fade these sounds in and out
            -- self.engineStartSound:play()
            self.engineLoopSound:play()
        end

        local depletionAmount = self.gasDepletionRate * dt
        if didAccelerate and didMoveForward then
            depletionAmount = depletionAmount * Values.GAS_ACCELERATION_DEPLETION_MULTIPLIER
        end
        self.gasRemaining = self.gasRemaining - depletionAmount
        GameUi.gasMeterShader:send("progress", self.gasRemaining / Values.FULL_GAS_AMOUNT)
        if self.gasRemaining <= 0 then
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

    if didMoveForward then
        self.sprite = self.sprites[2]
    else
        self.sprite = self.sprites[1]
    end
    local rotSegmentLength = 2 * math.pi / self.sprite.animations[self.sprite.currentAnimationState].numFrames
    local frameIdx = math.floor((((self.rotation + (rotSegmentLength / 2)) % (2 * math.pi)) / rotSegmentLength)) + 1
    self.sprite.animations[self.sprite.currentAnimationState].currentFrame = frameIdx

    self:updateNeighborTiles()
    self:updateTrailPositions(dt)

    local tilemapPosition =
        Vec2.new(self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)))
    local newTilemapPosition = Vec2.new(
        self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, -self.speed * dt))
    )
    local tilemapPositionUpdate = newTilemapPosition - tilemapPosition
    local tileFrom = Vec2.new()
    local tileTo = Collision.getPositionUpdate(self, self.neighborTiles, tilemapPositionUpdate)
    local worldFrom = Vec2.new(self.tilemap.tilemapIndexToWorldTransform:transformPoint(tileFrom.x, tileFrom.y))
    local worldTo = Vec2.new(self.tilemap.tilemapIndexToWorldTransform:transformPoint(tileTo.x, tileTo.y))

    local boatFrom = Vec2.new(self.transform:inverse():transformPoint(worldFrom.x, worldFrom.y))
    local boatTo = Vec2.new(self.transform:inverse():transformPoint(worldTo.x, worldTo.y))
    local boatUpdate = boatTo - boatFrom
    self.transform:translate(boatUpdate.x, boatUpdate.y)

    self.sprite.zIndex = self:getWorldRowIdx()

    BoatEffect.update(cameraObj)
end

local function draw(sprite, transform)
    love.graphics.push()
    local boatX, boatY = transform:transformPoint(0, 0)
    BoatEffect.setShader()
    love.graphics.draw(
        sprite.image,
        Animation.getCurrentQuad(Sprite.getCurrentAnimation(sprite)),
        boatX + sprite.xOffset,
        boatY + sprite.yOffset
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
        local boatPos = Vec2.new(self.transform:transformPoint(0, 0))
        local packagePos = Vec2.new(package.transform:transformPoint(0, 0))
        local packageDistance = boatPos:distanceTo(packagePos)
        if packageDistance <= self.interactionRadius and (not closestDistance or packageDistance < closestDistance) then
            closestPackage = package
            closestDistance = packageDistance
        end

        ::continue::
    end

    return closestPackage
end

local function pickupPackage(self, packages, mailboxes)
    local packageToPickup = self:findPackageToPickup(packages)
    if packageToPickup then
        table.insert(self.packages, packageToPickup)
        packageToPickup.sprite.shouldDraw = false
        packageToPickup:onPickup(self)
        return true
    end
    return false
end

local function getDeliveryMailbox(self, mailboxes)
    local boatPosition = Vec2.new(self.transform:transformPoint(0, 0))
    local package = self.packages[#self.packages]

    if not package then
        return nil
    end

    for _, mailbox in ipairs(mailboxes) do
        local mailboxPosition = Vec2.new(mailbox.transform:transformPoint(0, 0))
        if
            boatPosition:distanceTo(mailboxPosition) <= self.interactionRadius
            and mailbox.id == package.destinationId
            and package.canDeliver
        then
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
    return Vec2.new(self.tilemap.worldToTilemapIndexTransform:transformPoint(self.transform:transformPoint(0, 0)))
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

function Boat.new(tilemap, dayValue)
    local sprites = {}

    local boatImage = love.graphics.newImage("assets/art/boat1.png")
    local spriteStatic =
        Sprite.newAnimated(boatImage, NUM_BOAT_ANGLES, 0, false, -BOAT_WIDTH / 2, -BOAT_HEIGHT + (8 / 2), 0, 0)
    spriteStatic.draw = draw
    table.insert(sprites, spriteStatic)

    local boatAccelImage = love.graphics.newImage("assets/art/boat2.png")
    local spriteAccel =
        Sprite.newAnimated(boatAccelImage, NUM_BOAT_ANGLES, 0, false, -BOAT_WIDTH / 2, -BOAT_HEIGHT + (8 / 2), 0, 0)
    spriteAccel.draw = draw
    table.insert(sprites, spriteAccel)

    BoatEffect.load()

    local bumpSound = love.audio.newSource("assets/sound/bump.ogg", "static")
    local engineStartSound = love.audio.newSource("assets/sound/engine_start.ogg", "static")
    local engineLoopSound = love.audio.newSource("assets/sound/engine_loop.ogg", "static")
    engineLoopSound:setLooping(true)
    engineLoopSound:setVolume(0.25)

    local transform = love.math.newTransform(0, 300)
    local position = Vec2.new(transform:transformPoint(0, 0))
    local trailPositions = {}
    for _ = 1, NUM_TRAIL_POSITIONS do
        table.insert(trailPositions, position)
    end

    local initialGasAmount = Values.DAY_TO_GAS_AMOUNT[dayValue] or Values.FULL_GAS_AMOUNT
    GameUi.gasMeterShader:send("progress", initialGasAmount / Values.FULL_GAS_AMOUNT)

    return {
        -- TODO: build the boat from a tile object
        sprites = sprites,
        sprite = spriteStatic,
        transform = transform,

        bumpSound = bumpSound,
        engineStartSound = engineStartSound,
        engineLoopSound = engineLoopSound,

        getPosition = getPosition,
        onCollision = onCollision,
        collider = { width = 1, height = 1 },
        collidingWith = Set.new(),

        neighborTiles = {},
        updateNeighborTiles = updateNeighborTiles,

        trailPositions = trailPositions,
        updateTrailPositions = updateTrailPositions,

        speed = 0,
        maxSpeed = Values.BOAT_MAX_SPEED_DEFAULT,
        maxBackwardsSpeed = Values.BOAT_MAX_BACKWARD_SPEED_DEFAULT,
        acceleration = Values.BOAT_ACCELERATION_DEFAULT,
        deceleration = Values.BOAT_DECELERATION_DEFAULT,
        rotation = 0,
        rotationSpeed = Values.BOAT_ROTATION_SPEED_DEFAULT,
        interactionRadius = Values.BOAT_INTERACTION_RADIUS,
        packages = {},
        gasRemaining = initialGasAmount,
        gasDepletionRate = Values.GAS_DEPLETION_RATE_DEFAULT,

        isLanternActive = false,
        autoAccelerate = false,
        tilemap = tilemap,

        update = update,
        indexOfPackage = indexOfPackage,
        findPackageToPickup = findPackageToPickup,
        pickupPackage = pickupPackage,
        getDeliveryMailbox = getDeliveryMailbox,
        deliverPackage = deliverPackage,
        getWorldRowIdx = getWorldRowIdx,
    }
end

return Boat
