local Font = {
    large = nil,
    medium = nil,
    small = nil,
}

local CHAR_LAYOUT = "abcdefghijklmnopqrstuvwxyz0123456789'., "

function Font.load()
    Font.large = love.graphics.newImageFont("assets/art/font_large.png", CHAR_LAYOUT)
    Font.medium = love.graphics.newImageFont("assets/art/font_medium.png", CHAR_LAYOUT)
    Font.small = love.graphics.newImageFont("assets/art/font_small.png", CHAR_LAYOUT)
end

return Font
