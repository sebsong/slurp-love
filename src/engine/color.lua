local function hexToColorAmount(hexSubString)
	return tonumber(hexSubString, 16) / 255
end

local function hexToRGBA(hexString)
	local red = hexToColorAmount(string.sub(hexString, 1, 2))
	local green = hexToColorAmount(string.sub(hexString, 3, 4))
	local blue = hexToColorAmount(string.sub(hexString, 5, 6))
	return { red, green, blue, 1 }
end

function LoadColorPalette(hexFilePath)
	local colorPalette = {}
	for hexColor in love.filesystem.lines(hexFilePath) do
		table.insert(colorPalette, hexToRGBA(hexColor))
	end

	return colorPalette
end
