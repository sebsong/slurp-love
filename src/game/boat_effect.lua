local boatEffect = {}

local waterEffect = require("game/water_effect")

local SHADER_FILE_PATH = "assets/shader/boat.glsl"

boatEffect.VERTICAL_AMPLITUDE = 0.01

local shader

function boatEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader = love.graphics.newShader(SHADER_FILE_PATH)
	shader:send("VERTICAL_FREQ", waterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", waterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", boatEffect.VERTICAL_AMPLITUDE)
end

function boatEffect.update(camera)
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("time", love.timer.getTime())
end

function boatEffect.setShader()
	love.graphics.setShader(shader)
end

return boatEffect
