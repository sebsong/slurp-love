local packageEffect = {}

local color = require("engine/color")

local OUTLINE_COLOR_IDX = 7
local SHADER_FILE_PATH = "assets/shader/package.glsl"

local shader

function packageEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("OUTLINE_COLOR", color.palette[OUTLINE_COLOR_IDX])
end

function packageEffect.update()
end

function packageEffect.setShader(boat, packages, package)
	local showOutline = boat:findPackageToPickup(packages) == package

	shader:send("showOutline", showOutline)
	love.graphics.setShader(shader)
end

return packageEffect
