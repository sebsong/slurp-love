local Map = {}

local Align = require("engine.ui.align")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")

local mapOverlay

function Map.open()
    SceneManager.scenes.map:start()
end

function Map.close()
    SceneManager.scenes.map:stop()
end

function Map:load()
    local mapImage = love.graphics.newImage("assets/art/map.png")
    local mapSprite = Sprite.new(mapImage)
    mapOverlay = {
        sprite = mapSprite,
        transform = Align.screenAlignedTransform(mapSprite.width, mapSprite.height, "center", "center"),
    }
end

function Map:draw()
    love.graphics.push()

    love.graphics.setShader()
    mapOverlay.sprite:draw(mapOverlay.transform)

    love.graphics.pop()
end

return Map
