local debug = {}

function debug:printArray(array)
	local str = ""

	for _, val in ipairs(array) do
		str = string.format("%s %s", str, val)
	end
end

function debug:printMatrix(matrix)
	for _, row in ipairs(matrix) do
		debug:printArray(row)
	end
end

return debug
