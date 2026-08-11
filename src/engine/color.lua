---@class Color
---@field palette ColorPalette
---
---@field loadPalette fun(hexFilePath: string)
local Color = {}

---@alias ColorPalette number[][]

local function hexToColorPercent(hexSubString)
    return tonumber(hexSubString, 16) / 255
end

local function hexToRGBA(hexString)
    local red = hexToColorPercent(string.sub(hexString, 1, 2))
    local green = hexToColorPercent(string.sub(hexString, 3, 4))
    local blue = hexToColorPercent(string.sub(hexString, 5, 6))
    return { red, green, blue, 1 }
end

function Color.loadPalette(hexFilePath)
    Color.palette = {}
    local isBlankColor = true
    for hexColor in love.filesystem.lines(hexFilePath) do
        if isBlankColor then
            isBlankColor = false
            goto continue
        end
        table.insert(Color.palette, hexToRGBA(hexColor))
        ::continue::
    end
end

return Color
