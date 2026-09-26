---@class Scene
---@field isGlobal boolean
---@field isActive boolean
---@field isPaused boolean
---@field isInputPaused boolean
---@field shouldLoad boolean
---@field shouldUnload boolean
---@field baseScene Scene?
---@field subScene Scene?
---
---@field load fun(self: Scene)?
---@field unload fun(self: Scene)?
---@field onPause fun(self: Scene)?
---@field onResume fun(self: Scene)?
---@field onPauseInput fun(self: Scene)?
---@field onResumeInput fun(self: Scene)?
---@field keypressed fun(self: Scene, key: love.KeyConstant, scancode: love.Scancode, isRepeat: boolean)?
---@field keyreleased fun(self: Scene, key: love.KeyConstant, scancode: love.Scancode)?
---@field mousepressed fun(self: Scene, x: number, y: number, button: number, isTouch: boolean, presses: number)?
---@field mousemoved fun(self: Scene, x: number, y: number, dx: number, dy: number, isTouch: boolean)?
---@field wheelmoved fun(self: Scene, x: number, y: number)?
---@field update fun(self: Scene, dt: number)?
---@field draw fun(self: Scene)?
local Scene = {}
Scene.__index = Scene

---@param isGlobal boolean?
function Scene.new(isGlobal)
    ---@type Scene
    local scene = {
        isGlobal = isGlobal or false,
        isActive = false,
        isPaused = false,
        isInputPaused = false,
        shouldLoad = false,
        shouldUnload = false,
    }
    setmetatable(scene, Scene)

    return scene
end

---@param subScene Scene
---@return Scene
function Scene:compose(subScene)
    self.subScene = subScene
    subScene.baseScene = self
    return self
end

return Scene
