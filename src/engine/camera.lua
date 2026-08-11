local Settings = require("engine.settings")

---@class Camera
---@field transform love.Transform
---@field screenWidth number
---@field screenHeight number
---@field isPanning boolean
---@field panSpeed number
---@field zoom number
---@field zoomToggleIdx number
---@field zoomToggles number[]
---@field zoomSpeed number
---
---@field new fun(): Camera
---
---@field getScreenWidth fun(self: Camera): number
---@field getScreenHeight fun(self: Camera): number
---@field toggleZoom fun(self: Camera)
---@field resetZoom fun(self: Camera)
---@field togglePan fun(self: Camera)
---@field keyPressed fun(self: Camera, key: love.KeyConstant, scancode: love.Scancode, isRepeat: boolean)
---@field mousepressed fun(self: Camera, x: number, y: number, button: number, isTouch: boolean, presses: number)
---@field mousemoved fun(self: Camera, x: number, y: number, dx: number, dy: number, isTouch: boolean)
---@field wheelmoved fun(self: Camera, x: number, y: number)
---@field update fun(self: Camera, dt: number)
---@field getWorldToCanvasTransform fun(self: Camera): love.Transform
---@field getCanvasToWorldTransform fun(self: Camera): love.Transform
local Camera = {}
Camera.__index = Camera

function Camera.new()
    local zoomToggles = { 1, 0.5 }
    local newCamera = {
        transform = love.math.newTransform(),

        screenWidth = Settings.canvasPixelWidth,
        screenHeight = Settings.canvasPixelHeight,
        isPanning = false,
        panSpeed = 0.5,
        zoom = zoomToggles[1],
        zoomToggleIdx = 1,
        zoomToggles = zoomToggles,
        zoomSpeed = 1.1,
    }
    setmetatable(newCamera, Camera)

    return newCamera
end

function Camera:getScreenWidth()
    return self.screenWidth / self.zoom
end

function Camera:getScreenHeight()
    return self.screenHeight / self.zoom
end

function Camera:toggleZoom()
    self.zoomToggleIdx = math.max((self.zoomToggleIdx + 1) % (#self.zoomToggles + 1), 1)
    self.zoom = self.zoomToggles[self.zoomToggleIdx]
end

function Camera:resetZoom()
    self.zoom = self.zoomToggles[self.zoomToggleIdx]
end

function Camera:togglePan()
    self.isPanning = not self.isPanning
    love.mouse.setRelativeMode(self.isPanning)

    if not self.isPanning then
        self:resetZoom()
    end
end

function Camera:keypressed(key, scancode, isRepeat)
    if key == "return" and not isRepeat then
        self:toggleZoom()
    end

    if key == "`" and not isRepeat then
        self:togglePan()
    end
end

function Camera:mousepressed(x, y, button, isTouch, presses)
    if button == 3 then
        self:togglePan()
    end
end

function Camera:mousemoved(x, y, dx, dy, isTouch)
    if self.isPanning then
        self.transform:translate(dx * self.panSpeed, dy * self.panSpeed)
    end
end

function Camera:wheelmoved(x, y)
    if self.isPanning and y ~= 0 then
        local cameraZoomMultiplier = self.zoomSpeed
        if y < 0 then
            cameraZoomMultiplier = 1 / cameraZoomMultiplier
        end
        self.zoom = self.zoom * cameraZoomMultiplier
    end
end

function Camera:update(dt) end

function Camera:getWorldToCanvasTransform()
    local camX, camY = self.transform:transformPoint(0, 0)
    return love.math.newTransform(-camX + (self:getScreenWidth() / 2), -camY + (self:getScreenHeight() / 2))
end

function Camera:getCanvasToWorldTransform()
    return self:getWorldToCanvasTransform():inverse()
end

return Camera
