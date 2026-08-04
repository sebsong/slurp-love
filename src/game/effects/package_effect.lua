local PackageEffect = {}

local Color = require("engine/color")

local OUTLINE_COLOR_IDX = 7
local SHADER_FILE_PATH = "assets/shader/outline.glsl"

local shader
local packageToPickup

function PackageEffect.load()
    shader = love.graphics.newShader(SHADER_FILE_PATH)

    shader:send("OUTLINE_COLOR", Color.palette[OUTLINE_COLOR_IDX])
end

function PackageEffect.update(boat, packages)
    packageToPickup = boat:findPackageToPickup(packages)
end

function PackageEffect.setShader(package)
    local showOutline = package ~= nil and package == packageToPickup
    shader:send("showOutline", showOutline)
    love.graphics.setShader(shader)
end

return PackageEffect
