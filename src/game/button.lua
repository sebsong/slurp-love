local Button = require("engine.ui.button")

local GameButton = {}

local buttonHoverSound
local buttonPressSound

function GameButton.load()
    buttonHoverSound = love.audio.newSource("assets/sound/button_hover.ogg", "static")
    buttonPressSound = love.audio.newSource("assets/sound/button_press.ogg", "static")
end

function GameButton.new(image, transform, font, text, onHover, onPress)
    GameButton.load() -- TODO: move this and other asset loading into an asset loader
    return Button.new(image, transform, font, text, buttonHoverSound, buttonPressSound, onHover, onPress)
end

return GameButton
