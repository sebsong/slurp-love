local font = {
	default = nil
}

function font.load()
	font.default = love.graphics.newImageFont("assets/art/font.png", " abcdefghijklmnopqrstuvwxyz0123456789")
end

return font
