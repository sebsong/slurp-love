---@class Scene
---@field init fun(self: Scene, isGlobal: boolean?)
---@field start fun(self: Scene)
---@field stop fun(self: Scene)
---@field pause fun(self: Scene)
---@field resume fun(self: Scene)
---@field pauseInput fun(self: Scene)
---@field resumeInput fun(self: Scene)
---@field restart fun(self: Scene)
---
---@field isGlobal boolean
---@field isActive boolean
---@field isPaused boolean
---@field isInputPaused boolean
---@field shouldLoad boolean
---@field shouldUnload boolean
---
---@field load fun()
---@field unload fun()
---@field onPause fun()
---@field onResume fun()
---@field keyPressed fun(key: love.KeyConstant, scancode: love.Scancode, isRepeat: boolean)?
---@field mousepressed fun(x: number, y: number, button: number, isTouch: boolean, presses: number)?
---@field mousemoved fun(x: number, y: number, dx: number, dy: number, isTouch: boolean)?
---@field wheelmoved fun(x: number, y: number)?
---@field update fun(dt: number)
---@field draw fun()
local Scene = {}
Scene.__index = Scene

function Scene:init(isGlobal)
    assert(self.load, "Scene %s missing load method")
    assert(self.unload, "Scene missing unload method")
    assert(self.onPause, "Scene missing onPause method")
    assert(self.onResume, "Scene missing onResume method")
    assert(self.update, "Scene missing update method")
    assert(self.draw, "Scene missing draw method")

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
    self.onPause()
    self.isPaused = true
end

function Scene:resume()
    self.onResume()
    self.isPaused = false
end

function Scene:pauseInput()
    self.isInputPaused = true
end

function Scene:resumeInput()
    self.isInputPaused = false
end

function Scene:restart()
    self:stop()
    self:start()
end

return Scene
