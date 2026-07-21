local font = {
	default = nil,
	small = nil,
}

local CHAR_LAYOUT = "abcdefghijklmnopqrstuvwxyz0123456789'. "

function font.load()
	font.default = love.graphics.newImageFont("assets/art/font.png", CHAR_LAYOUT)
	font.small = love.graphics.newImageFont("assets/art/font_small.png", CHAR_LAYOUT)
end

return font
