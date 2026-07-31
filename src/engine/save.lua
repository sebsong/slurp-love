local Save = {}

local Serialization = require("engine/serialization")

local SAVE_FILE_NAME = "save_data.slurp"

function Save.save(data)
	Serialization.tableToFile(data, SAVE_FILE_NAME)
end

function Save.load()
	return Serialization.fileToTable(SAVE_FILE_NAME)
end

return Save
