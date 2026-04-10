local file = {}

function file.assertFileExtension(filePath, expectedFileExt)
	local fileExt = string.sub(filePath, string.find(filePath, "%.%a+") or #filePath - 3, #filePath)
	assert(
		fileExt == expectedFileExt,
		string.format("Wrong file format, expected %s but got: %s", expectedFileExt, fileExt)
	)
end

function file.stripFileExtension(filePath)
	local first, _ = string.find(filePath, "%.%a+")
	if first then
		return string.sub(filePath, 1, first - 1)
	end
	return string.sub(filePath, 1, #filePath - 4)
end

return file
