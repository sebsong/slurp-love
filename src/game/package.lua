local PackageEffect = require("game.effects.package_effect")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")

local PackageDetail = require("game.scenes.package_detail")
local Values = require("game.values")

local Package = {}
Package.__index = Package

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

function Package:onPickup(boat)
    local tileId = self.tileId

    SceneManager.scenes.game:pause()
    PackageDetail.open(tileId, function()
        SceneManager.scenes.game:resume()
    end)

    if tileId == Values.PACKAGE_TYPES.GLASS then
        self.cracksRemaining = 3
    elseif tileId == Values.PACKAGE_TYPES.LEAD_FOOT then
        boat.autoAccelerate = true
    elseif tileId == Values.PACKAGE_TYPES.LANTERN then
        boat.isLanternActive = true
    elseif tileId == Values.PACKAGE_TYPES.FEATHER then
        boat.maxSpeed = boat.maxSpeed * 2
    elseif tileId == Values.PACKAGE_TYPES.MIRROR then
        reversePackageOrder(boat)
    end
end

function Package:onDeliver(boat)
    local tileId = self.tileId

    if tileId == Values.PACKAGE_TYPES.GLASS then
    elseif tileId == Values.PACKAGE_TYPES.LEAD_FOOT then
        boat.autoAccelerate = false
    elseif tileId == Values.PACKAGE_TYPES.LANTERN then
        boat.isLanternActive = false
    elseif tileId == Values.PACKAGE_TYPES.FEATHER then
        boat.maxSpeed = boat.maxSpeed / 2
    elseif tileId == Values.PACKAGE_TYPES.MIRROR then
        reversePackageOrder(boat)
    end
end

function Package:onCollision(boat, _collidable)
    if self.tileId == Values.PACKAGE_TYPES.GLASS then
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

function Package:update(dt) end

function Package.load()
    crack1Sound = love.audio.newSource("assets/sound/crack_1.ogg", "static")
    crack1Sound:setVolume(0.5)
    crack2Sound = love.audio.newSource("assets/sound/crack_2.ogg", "static")
    crack2Sound:setVolume(0.5)
    crackSounds = { crack2Sound, crack1Sound }
    shatterSound = love.audio.newSource("assets/sound/shatter.ogg", "static")
    shatterSound:setVolume(0.5)
end

function Package.new(image, tileObject, tilemap)
    local packageSprite = Sprite.newTiled(image, 5, tileObject.tileId)
    packageSprite.xOffset = -packageSprite.width / 2
    packageSprite.yOffset = -packageSprite.height + tilemap.tileHeight / 2
    local package = {
        transform = tileObject.transform,
        sprite = packageSprite,

        tileId = tileObject.tileId,
        destinationId = tileObject.properties.destination.id,
        isDelivered = false,
        canDeliver = true,
        mailbox = nil,
    }

    packageSprite.setShader = function()
        PackageEffect.setShader(package)
    end

    setmetatable(package, Package)
    return package
end

return Package
