local floatingTileEffect = {}

local waterEffect = require("game/water_effect")
local boatEffect = require("game/boat_effect")

local SHADER_FILE_PATH = "assets/shader/floating_tile.glsl"

local shader

function floatingTileEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)
	shader:send("VERTICAL_FREQ", waterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", waterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", boatEffect.VERTICAL_AMPLITUDE)
end

function floatingTileEffect.update(camera)
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("time", love.timer.getTime())
end

function floatingTileEffect.setShader(tile)
	shader:send("tilePosition", { tile.transform:transformPoint(0, 0) })
	love.graphics.setShader(shader)
end

return floatingTileEffect
