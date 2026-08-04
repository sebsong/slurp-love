local Package = {
    type = {
        GLASS = 1,
        LEAD_FOOT = 2,
        LANTERN = 3,
        RADIOACTIVE_JUNK = 4,
        MIRROR = 5,
    },
}
local meta = {}
meta.__index = meta

local Scene = require("engine/scene")

local PackageDetail = require("game/package_detail")

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

    Scene.pause(Scene.scenes.game)
    PackageDetail.open(tileId, function()
        Scene.resume(Scene.scenes.game)
    end)

    if tileId == Package.type.GLASS then
        self.cracksRemaining = 3
    elseif tileId == Package.type.LEAD_FOOT then
        boat.autoAccelerate = true
    elseif tileId == Package.type.LANTERN then
        boat.isLanternActive = true
    elseif tileId == Package.type.RADIOACTIVE_JUNK then
        boat.maxSpeed = boat.maxSpeed * 2
    elseif tileId == Package.type.MIRROR then
        reversePackageOrder(boat)
    end
end

function meta:onDeliver(boat)
    local tileId = self.tileId

    if tileId == Package.type.GLASS then
    elseif tileId == Package.type.LEAD_FOOT then
        boat.autoAccelerate = false
    elseif tileId == Package.type.LANTERN then
        boat.isLanternActive = false
    elseif tileId == Package.type.RADIOACTIVE_JUNK then
        boat.maxSpeed = boat.maxSpeed / 2
    elseif tileId == Package.type.MIRROR then
        reversePackageOrder(boat)
    end
end

function meta:onCollision(boat, _collidable)
    if self.tileId == Package.type.GLASS then
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

function meta:update(dt) end

function Package.load()
    crack1Sound = love.audio.newSource("assets/sound/crack_1.ogg", "static")
    crack1Sound:setVolume(0.5)
    crack2Sound = love.audio.newSource("assets/sound/crack_2.ogg", "static")
    crack2Sound:setVolume(0.5)
    crackSounds = { crack2Sound, crack1Sound }
    shatterSound = love.audio.newSource("assets/sound/shatter.ogg", "static")
    shatterSound:setVolume(0.5)
end

function Package.toPackage(tileObject)
    setmetatable(tileObject, meta)
    tileObject.destinationId = tileObject.properties.destination.id
    tileObject.isDelivered = false
    tileObject.canDeliver = true
    return tileObject
end

return Package
