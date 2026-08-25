local PackageEffect = {}

local Color = require("engine.color")

local SHADER_FILE_PATH = "assets/shader/outline.glsl"

local shader
local packageToPickup

function PackageEffect.load()
    shader = love.graphics.newShader(SHADER_FILE_PATH)

    shader:send("OUTLINE_COLOR", Color.palette[1])
    shader:send("HIGHLIGHT_COLOR", Color.palette[7])
end

function PackageEffect.update(boat, packages)
    packageToPickup = boat:findPackageToPickup(packages)
end

function PackageEffect.setShader(package)
    local highlightOutline = package ~= nil and package == packageToPickup
    shader:send("highlightOutline", highlightOutline)
    love.graphics.setShader(shader)
end

return PackageEffect
