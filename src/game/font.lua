local font = {
	large = nil,
	medium = nil,
	small = nil,
}

local CHAR_LAYOUT = "abcdefghijklmnopqrstuvwxyz0123456789'., "

function font.load()
	font.large = love.graphics.newImageFont("assets/art/font_large.png", CHAR_LAYOUT)
	font.medium = love.graphics.newImageFont("assets/art/font_medium.png", CHAR_LAYOUT)
	font.small = love.graphics.newImageFont("assets/art/font_small.png", CHAR_LAYOUT)
end

return font
