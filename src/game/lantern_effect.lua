local lanternEffect = {}

local canvas = require("engine/canvas")
local color = require("engine/color")
local waterEffect = require("game/water_effect")

local SHADER_FILE_PATH = "assets/shader/lantern.glsl"

local shader
local shaderFileModTime

function lanternEffect.load()
	shader = love.graphics.newShader("assets/shader/lantern.glsl")

	shader = love.graphics.newShader(SHADER_FILE_PATH)
	shader:send("VERTICAL_FREQ", waterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", waterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", 0.01)

	shader:send("canvasDimensions", { canvas.canvas:getPixelWidth(), canvas.canvas:getPixelHeight() })
	shader:send("colorPalette", unpack(color.palette))
	shader:send("colorMapping", unpack({ 1, 2, 3, 4, 5, 6, 7, 6 }))
end

function lanternEffect.update(camera)
	local modTime = love.filesystem.getInfo(SHADER_FILE_PATH).modtime
	if (modTime ~= shaderFileModTime) then
		lanternEffect.load()
	end
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("time", love.timer.getTime())
end

function lanternEffect.setShader()
	shader:send("canvasImage", canvas.canvas)
	love.graphics.setShader(shader)
end

return lanternEffect
