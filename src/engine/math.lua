local slurp_math = {}

local vec2 = require("engine/vec2")

function slurp_math.distance(from, to)
	return math.sqrt((to.x - from.x) ^ 2 + (to.y - from.y) ^ 2)
end

function slurp_math.absMin(v1, ...)
	local minAbs = math.abs(v1)
	local min = v1

	for _, val in ipairs({ ... }) do
		local valAbs = math.abs(val)
		if valAbs < minAbs then
			minAbs = valAbs
			min = val
		end
	end

	return min
end

function slurp_math.inEllipse(xRadius, yRadius, ellipsePosition, testPosition)
	local positionDiff = testPosition - ellipsePosition
	return ((positionDiff.x / xRadius) ^ 2 + (positionDiff.y / yRadius) ^ 2) <= 1
end

return slurp_math
