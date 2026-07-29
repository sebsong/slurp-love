local Debug = {}

local stopwatchTime

function Debug.printArray(array)
	local str = ""

	for _, val in ipairs(array) do
		str = string.format("%s %s", str, val)
	end
end

function Debug.printMatrix(matrix)
	for _, row in ipairs(matrix) do
		Debug.printArray(row)
	end
end

function Debug.stopwatch(label)
	local endTime = love.timer.getTime()
	local elapsedMs = stopwatchTime and (endTime - stopwatchTime) * 1000 or nil
	stopwatchTime = endTime
	if label then
		print(("%s: %s"):format(label, elapsedMs))
	end
	return elapsedMs
end

return Debug
