---@class Scene
---@field isGlobal boolean
---@field isActive boolean
---@field isPaused boolean
---@field isInputPaused boolean
---@field shouldLoad boolean
---@field shouldUnload boolean
---
---@field load fun(self: Scene)
---@field unload fun(self: Scene)
---@field onPause fun(self: Scene)?
---@field onResume fun(self: Scene)?
---@field onPauseInput fun(self: Scene)?
---@field onResumeInput fun(self: Scene)?
---@field keypressed fun(self: Scene, key: love.KeyConstant, scancode: love.Scancode, isRepeat: boolean)?
---@field keyreleased fun(self: Scene, key: love.KeyConstant, scancode: love.Scancode)?
---@field mousepressed fun(self: Scene, x: number, y: number, button: number, isTouch: boolean, presses: number)?
---@field mousemoved fun(self: Scene, x: number, y: number, dx: number, dy: number, isTouch: boolean)?
---@field wheelmoved fun(self: Scene, x: number, y: number)?
---@field update fun(self: Scene, dt: number)
---@field draw fun(self: Scene)
local Scene = {}
Scene.__index = Scene

---@param isGlobal boolean
function Scene:init(isGlobal)
    self.isGlobal = isGlobal
    self.isActive = false
    self.isPaused = false
    self.isInputPaused = false
    self.shouldLoad = false
    self.shouldUnload = false
    setmetatable(self, Scene)
end

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

return Scene
