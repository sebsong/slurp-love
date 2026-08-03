local Serialization = {}

function Serialization.primitiveToString(primitive)
	local primitiveType = type(primitive)

	assert(
		primitiveType == "number"
		or primitiveType == "boolean"
		or primitiveType == "string",
		"must be a supported primitive type"
	)

	if primitiveType == "string" then
		return ("\"%s\""):format(primitive)
	end

	return ("%s"):format(primitive)
end

function Serialization.tableToString(tbl, indentLevel)
	assert(type(tbl) == "table", "must be a table")

	indentLevel = indentLevel or 0

	local str = ""
	str = str .. "{\n"

	local sortedKeys = {}
	for key, _ in pairs(tbl) do
		table.insert(sortedKeys, key)
	end
	table.sort(sortedKeys)

	for _, key in ipairs(sortedKeys) do
		local val = tbl[key]
		local valString
		if type(val) == "table" then
			valString = Serialization.tableToString(val, indentLevel + 1)
		else
			valString = Serialization.primitiveToString(val)
		end

		local keyString = type(key) == "number" and ("[%s]"):format(key) or key
		str = str .. ("%s%s = %s,\n"):format(("\t"):rep(indentLevel + 1), keyString, valString)
	end
	str = str .. ("%s}"):format(("\t"):rep(indentLevel))

	return str
end

function Serialization.tableToFile(tbl, fileName)
	local fileString = ("return %s\n"):format(Serialization.tableToString(tbl))
	local file = love.filesystem.newFile(fileName, "w")
	file:write(fileString)
end

function Serialization.fileToTable(fileName)
	local file = love.filesystem.newFile(fileName, "r")
	if not file then
		return {}
	end

	local saveDataString, _ = file:read()
	local saveData = loadstring(saveDataString)()
	return saveData or {}
end

return Serialization
