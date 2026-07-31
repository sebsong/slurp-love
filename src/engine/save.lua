local Save = {}

local SAVE_FILE_NAME = "save_data.slurp"

-- TODO: handle nested tables
function Save.save(data)
	assert(type(data) == "table", "save data must be a table")

	local file = love.filesystem.newFile(SAVE_FILE_NAME, "w")
	file:write("return {\n")
	for key, val in pairs(data) do
		file:write(("\t%s = %s,"):format(key, val))
	end
	file:write("\n}\n")
end

function Save.load()
	local file = love.filesystem.newFile(SAVE_FILE_NAME, "r")
	if not file then
		return {}
	end

	local saveDataString, _ = file:read()
	local saveData = loadstring(saveDataString)()
	return saveData
end

return Save
