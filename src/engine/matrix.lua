local debug = require("engine/debug")

function GetTransposed(matrix)
	local transposed = {}
	for i, row in ipairs(matrix) do
		for j, val in ipairs(row) do
			if not transposed[j] then
				transposed[j] = {}
			end
			transposed[j][i] = val
		end
	end

	return transposed
end
