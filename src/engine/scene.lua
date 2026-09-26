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

-- TODO: all of these methods should be executed by the scene manager using processSceneStack
function Scene:start()
    self.isPaused = false
    self.shouldLoad = true
end

function Scene:stop()
    self.shouldUnload = true
end

function Scene:pause()
    self.isPaused = true
    if self.onPause then
        self:onPause()
    end
end

function Scene:resume()
    self.isPaused = false
    if self.onResume then
        self:onResume()
    end
end

function Scene:pauseInput()
    self.isInputPaused = true
    if self.onPauseInput then
        self:onPauseInput()
    end
end

function Scene:resumeInput()
    self.isInputPaused = false
    if self.onResumeInput then
        self:onResumeInput()
    end
end

function Scene:restart()
    self:stop()
    self:start()
end

---@param subScene Scene
---@return Scene
function Scene:compose(subScene)
    self.subScene = subScene
    subScene.baseScene = self
    return self
end

return Scene
