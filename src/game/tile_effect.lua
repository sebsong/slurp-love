local tileEffect = {}

local vec2 = require("engine/vec2")
local slurp_math = require("engine/math")
local color = require("engine/color")
local waterEffect = require("game/water_effect")
local boatEffect = require("game/boat_effect")

local SHADER_FILE_PATH = "assets/shader/tile.glsl"

local shader

function tileEffect.load(camera, boat)
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("VERTICAL_FREQ", waterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", waterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", waterEffect.VERTICAL_AMPLITUDE)
	shader:send("VERTICAL_AMPLITUDE_FLOAT", boatEffect.VERTICAL_AMPLITUDE)
	shader:send("FOAM_COLOR", color.palette[waterEffect.FOAM_INNER_COLOR_IDX])
end

function tileEffect.update(camera, boat)
	shader:send("isLanternActive", boat.isLanternActive)
	shader:send("time", love.timer.getTime())
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
end

function tileEffect.setShader(tile, boat, lanternXRadius, lanternYRadius)
	shader:send("quadViewport", { tile.tileQuad:getViewport() })
	shader:send("tilePosition", { tile.transform:transformPoint(0, 0) })
	shader:send("isFloating", tile.isFloating)
	local inRange = false
	if boat.isLanternActive and tile.isFloating then
		local boatPos = vec2.new(boat.transform:transformPoint(0, 0))
		local tilePos = vec2.new(tile.transform:transformPoint(0, 0))
		inRange = slurp_math.inEllipse(lanternXRadius, lanternYRadius, boatPos, tilePos)
	end
	shader:send("inRange", inRange)
	love.graphics.setShader(shader)
end

return tileEffect
