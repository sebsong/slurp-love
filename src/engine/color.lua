ColorPalette = nil;

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
	local isBlankColor = true
	for hexColor in love.filesystem.lines(hexFilePath) do
		if isBlankColor then
			isBlankColor = false
			goto continue
		end
		table.insert(colorPalette, hexToRGBA(hexColor))
		::continue::
	end

	ColorPalette = colorPalette

	return colorPalette
end
