local Math = {}

function Math.absMin(v1, ...)
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

function Math.clamped(val, min, max)
	return math.min(math.max(val, min), max)
end

function Math.inRange(val, min, max)
	return val >= min and val <= max
end

function Math.inEllipse(xRadius, yRadius, ellipsePosition, testPosition)
	local positionDiff = testPosition - ellipsePosition
	return ((positionDiff.x / xRadius) ^ 2 + (positionDiff.y / yRadius) ^ 2) <= 1
end

return Math
