local packageEffect = {}

local color = require("engine/color")

local OUTLINE_COLOR_IDX = 7
local SHADER_FILE_PATH = "assets/shader/package.glsl"

local shader
local packageToPickup

function packageEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("OUTLINE_COLOR", color.palette[OUTLINE_COLOR_IDX])
end

function packageEffect.update(boat, packages)
	packageToPickup = boat:findPackageToPickup(packages)
end

function packageEffect.setShader(package)
	shader:send("showOutline", package == packageToPickup)
	love.graphics.setShader(shader)
end

return packageEffect
