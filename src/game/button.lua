local Button = require("engine.ui.button")

local GameButton = {}

local buttonHoverSound
local buttonPressSound

function GameButton.load()
    buttonHoverSound = love.audio.newSource("assets/sound/button_hover.ogg", "static")
    buttonHoverSound:setVolume(0.25)
    buttonPressSound = love.audio.newSource("assets/sound/button_press.ogg", "static")
    buttonPressSound:setVolume(0.25)
end

function GameButton.new(image, transform, font, text, onHover, onPress)
    GameButton.load() -- TODO: move this and other asset loading into an asset loader
    return Button.new(image, transform, font, text, buttonHoverSound, buttonPressSound, onHover, onPress)
end

return GameButton
