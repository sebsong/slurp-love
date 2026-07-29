local LanternEffect = {}

local Canvas = require("engine/canvas")
local Color = require("engine/color")
local WaterEffect = require("game/effects/water_effect")
local BoatEffect = require("game/effects/boat_effect")

local SHADER_FILE_PATH = "assets/shader/lantern.glsl"

local shader

function LanternEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader = love.graphics.newShader(SHADER_FILE_PATH)
	shader:send("VERTICAL_FREQ", WaterEffect.VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", WaterEffect.VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", BoatEffect.VERTICAL_AMPLITUDE)

	shader:send("canvasDimensions", { Canvas.canvas:getPixelWidth(), Canvas.canvas:getPixelHeight() })
	shader:send("colorPalette", unpack(Color.palette))
	shader:send("colorMapping", unpack({ 1, 2, 3, 4, 5, 6, 7, 6 }))
end

function LanternEffect.update(camera)
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("time", love.timer.getTime())
end

function LanternEffect.setShader()
	shader:send("canvasImage", Canvas.canvas)
	love.graphics.setShader(shader)
end

return LanternEffect
