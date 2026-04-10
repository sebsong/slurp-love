local color = {}

color.palette = nil;

local function hexToColorPercent(hexSubString)
	return tonumber(hexSubString, 16) / 255
end

local function hexToRGBA(hexString)
	local red = hexToColorPercent(string.sub(hexString, 1, 2))
	local green = hexToColorPercent(string.sub(hexString, 3, 4))
	local blue = hexToColorPercent(string.sub(hexString, 5, 6))
	return { red, green, blue, 1 }
end

function color.loadPalette(hexFilePath)
	color.palette = {}
	local isBlankColor = true
	for hexColor in love.filesystem.lines(hexFilePath) do
		if isBlankColor then
			isBlankColor = false
			goto continue
		end
		table.insert(color.palette, hexToRGBA(hexColor))
		::continue::
	end

	return color.palette
end

return color
