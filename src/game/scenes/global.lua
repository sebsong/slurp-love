local Scene = require("engine.scene")
local SceneManager = require("engine.scene_manager")

local PauseMenu = require("game.scenes.pause_menu")

local Global = Scene.new(true)

function Global:keypressed(key, scancode, isRepeat)
    local gameScene = SceneManager.scenes.game
    if gameScene.isActive and love.keyboard.isDown("escape") and not isRepeat then
        PauseMenu.toggle()
    end
end

return Global
