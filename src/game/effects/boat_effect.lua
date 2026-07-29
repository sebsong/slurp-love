local BoatEffect = {}

local WaterEffect = require("game/effects/water_effect")

local SHADER_FILE_PATH = "assets/shader/boat.glsl"

BoatEffect.VERTICAL_AMPLITUDE = 0.01

local shader

function BoatEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)
	shader:send("VERTICAL_FREQ", WaterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", WaterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", BoatEffect.VERTICAL_AMPLITUDE)
end

function BoatEffect.update(camera)
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("time", love.timer.getTime())
end

function BoatEffect.setShader()
	love.graphics.setShader(shader)
end

return BoatEffect
