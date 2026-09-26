local Align = require("engine.ui.align")
local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")

---@class Map: Scene
local Map = Scene.new()

local mapOverlay

function Map.open()
    SceneManager.start(SceneManager.scenes.map)
end

function Map.close()
    SceneManager.stop(SceneManager.scenes.map)
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
