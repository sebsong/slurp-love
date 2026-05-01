local debug = {}

local stopwatchTime

function debug.printArray(array)
	local str = ""

	for _, val in ipairs(array) do
		str = string.format("%s %s", str, val)
	end
end

function debug.printMatrix(matrix)
	for _, row in ipairs(matrix) do
		debug.printArray(row)
	end
end

function debug.stopwatch(label)
	local endTime = love.timer.getTime()
	local elapsedMs = stopwatchTime and (endTime - stopwatchTime) * 1000 or nil
	stopwatchTime = endTime
	if label then
		print(("%s: %s"):format(label, elapsedMs))
	end
	return elapsedMs
end

return debug
