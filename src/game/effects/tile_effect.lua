local TileEffect = {}

local Vec2 = require("engine/vec2")
local Math = require("engine/math")
local Color = require("engine/color")
local WaterEffect = require("game/effects/water_effect")
local BoatEffect = require("game/effects/boat_effect")

local SHADER_FILE_PATH = "assets/shader/tile.glsl"

local shader

function TileEffect.load(camera, boat)
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("VERTICAL_FREQ", WaterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", WaterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", WaterEffect.VERTICAL_AMPLITUDE)
	shader:send("VERTICAL_AMPLITUDE_FLOAT", BoatEffect.VERTICAL_AMPLITUDE)
	shader:send("FOAM_COLOR", Color.palette[WaterEffect.FOAM_INNER_COLOR_IDX])
end

function TileEffect.update(camera, boat)
	shader:send("isLanternActive", boat.isLanternActive)
	shader:send("time", love.timer.getTime())
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
end

function TileEffect.setShader(tile, boat, lanternXRadius, lanternYRadius)
	shader:send("quadViewport", { tile.tileQuad:getViewport() })
	shader:send("tilePosition", { tile.transform:transformPoint(0, 0) })
	shader:send("isFloating", tile.isFloating)
	local inRange = false
	if boat.isLanternActive and tile.isFloating then
		local boatPos = Vec2.new(boat.transform:transformPoint(0, 0))
		local tilePos = Vec2.new(tile.transform:transformPoint(0, 0))
		inRange = Math.inEllipse(lanternXRadius, lanternYRadius, boatPos, tilePos)
	end
	shader:send("inRange", inRange)
	love.graphics.setShader(shader)
end

return TileEffect
