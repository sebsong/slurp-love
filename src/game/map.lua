local Map = {}

local Scene = require("engine.scene")
local Sprite = require("engine.sprite")
local Ui = require("engine.ui.ui")

local mapOverlay

function Map.open()
    Scene.start(Scene.scenes.map)
end

function Map.close()
    Scene.stop(Scene.scenes.map)
end

function Map.load()
    local mapImage = love.graphics.newImage("assets/art/map.png")
    local mapSprite = Sprite.new(mapImage)
    mapOverlay = {
        sprite = mapSprite,
        transform = Ui.newAlignedTransform(mapSprite.width, mapSprite.height, Ui.align.CENTER, Ui.align.CENTER),
    }
end

function Map.unload() end

function Map.onPause() end

function Map.onResume() end

function Map.keypressed(key, scancode, isRepeat) end

function Map.mousepressed(x, y, button, isTouch, presses) end

function Map.mousemoved(x, y, dx, dy, isTouch) end

function Map.wheelmoved(x, y) end

function Map.update(dt) end

function Map.draw()
    love.graphics.push()

    love.graphics.setShader()
    Sprite.draw(mapOverlay.sprite, mapOverlay.transform)

    love.graphics.pop()
end

return Map
