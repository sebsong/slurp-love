local waterEffect = {}

local color = require("engine/color")

local SHADER_FILE_PATH = "assets/shader/water.glsl"

local BASE_COLOR_IDX = 1
local FOAM_OUTER_COLOR_IDX = 2
local FOAM_OUTER_SIZE = 0.005;
local FOAM_INNER_COLOR_IDX = 3
local FOAM_INNER_SIZE = 0.002;
local FOAM_FILL_MULTIPLIER = 0.02;
local TRAIL_COLOR_IDX = 3

local NUM_COLUMNS = 16;
local NUM_ROWS = 32;
local GRID_WIDTH = 1 / NUM_COLUMNS;
local GRID_HEIGHT = 1 / NUM_ROWS;
local COLUMN_SEARCH_DIST = 1;
local ROW_SEARCH_DIST = 8;

local VERTICAL_FREQ = 13;
local VERTICAL_SPEED = -1;
local VERTICAL_AMPLITUDE = .1;
local HORIZONTAL_FREQ = 5;
local HORIZONTAL_SPEED = -0.25;
local HORIZONTAL_AMPLITUDE = .1;

local DEBUG_POINT_SIZE = 0.002;
local DEBUG_GRID_LINE_SIZE = 0.003;

local shader
local shaderFileModTime
local seed

function waterEffect.load(camera, boat, newSeed)
	shader            = love.graphics.newShader(SHADER_FILE_PATH)
	shaderFileModTime = love.filesystem.getInfo(SHADER_FILE_PATH).modtime
	seed              = newSeed
	shader:send("seed", seed)
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("boatPosition", { boat.transform:transformPoint(0, 0) })

	shader:send("BASE_COLOR", color.palette[BASE_COLOR_IDX])
	shader:send("FOAM_OUTER_COLOR", color.palette[FOAM_OUTER_COLOR_IDX])
	shader:send("FOAM_OUTER_SIZE", FOAM_OUTER_SIZE)
	shader:send("FOAM_INNER_COLOR", color.palette[FOAM_INNER_COLOR_IDX])
	shader:send("FOAM_INNER_SIZE", FOAM_INNER_SIZE)
	shader:send("FOAM_FILL_MULTIPLIER", FOAM_FILL_MULTIPLIER)
	shader:send("TRAIL_COLOR", color.palette[TRAIL_COLOR_IDX])

	shader:send("GRID_WIDTH", GRID_WIDTH)
	shader:send("GRID_HEIGHT", GRID_HEIGHT)
	shader:send("COLUMN_SEARCH_DIST", COLUMN_SEARCH_DIST)
	shader:send("ROW_SEARCH_DIST", ROW_SEARCH_DIST)

	shader:send("VERTICAL_FREQ", VERTICAL_FREQ)
	shader:send("VERTICAL_SPEED", VERTICAL_SPEED)
	shader:send("VERTICAL_AMPLITUDE", VERTICAL_AMPLITUDE)
	shader:send("HORIZONTAL_FREQ", HORIZONTAL_FREQ)
	shader:send("HORIZONTAL_SPEED", HORIZONTAL_SPEED)
	shader:send("HORIZONTAL_AMPLITUDE", HORIZONTAL_AMPLITUDE)

	-- shader:send("DEBUG_POINT_SIZE", DEBUG_POINT_SIZE)
	-- shader:send("DEBUG_GRID_LINE_SIZE", DEBUG_GRID_LINE_SIZE)
end

function waterEffect.update(camera, boat)
	local modTime = love.filesystem.getInfo(SHADER_FILE_PATH).modtime
	if (modTime ~= shaderFileModTime) then
		waterEffect.load(camera, boat, seed)
	end

	shader:send("time", love.timer.getTime())
	shader:send("cameraCanvasDimensions", { camera:getScreenWidth(), camera:getScreenHeight() })
	shader:send("cameraPosition", { camera.transform:transformPoint(0, 0) })
	shader:send("boatPosition", { boat.transform:transformPoint(0, 0) })
	shader:send("boatTrailPositions", unpack(boat.trailPositions))
end

function waterEffect.setShader()
	love.graphics.setShader(shader)
end

return waterEffect
