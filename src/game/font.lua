local font = {
	default = nil
}

function font.load()
	font.default = love.graphics.newImageFont("assets/art/font.png", "abcdefghijklmnopqrstuvwxyz")
end

return font
