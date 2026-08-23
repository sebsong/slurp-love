local Settings = require("engine.settings")

---@class Camera
---@field transform love.Transform
---@field screenWidth integer
---@field screenHeight integer
---@field isPanning boolean
---@field panSpeed number
---@field zoom number
---@field zoomToggleIdx integer
---@field zoomToggles integer[]
---@field zoomSpeed number
local Camera = {}
Camera.__index = Camera

---@return Camera
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

---@return integer
function Camera:getScreenWidth()
    return self.screenWidth / self.zoom
end

---@return integer
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

---@param key love.KeyConstant
---@param scancode love.Scancode
---@param isRepeat boolean
function Camera:keypressed(key, scancode, isRepeat)
    if key == "return" and not isRepeat then
        self:toggleZoom()
    end

    if key == "`" and not isRepeat then
        self:togglePan()
    end
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function Camera:mousepressed(x, y, button, isTouch, presses)
    if button == 3 then
        self:togglePan()
    end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param isTouch boolean
function Camera:mousemoved(x, y, dx, dy, isTouch)
    if self.isPanning then
        self.transform:translate(dx * self.panSpeed, dy * self.panSpeed)
    end
end

---@param x number
---@param y number
function Camera:wheelmoved(x, y)
    if self.isPanning and y ~= 0 then
        local cameraZoomMultiplier = self.zoomSpeed
        if y < 0 then
            cameraZoomMultiplier = 1 / cameraZoomMultiplier
        end
        self.zoom = self.zoom * cameraZoomMultiplier
    end
end

---@param dt number
function Camera:update(dt) end

---@return love.Transform
function Camera:getWorldToCanvasTransform()
    local camX, camY = self.transform:transformPoint(0, 0)
    return love.math.newTransform(-camX + (self:getScreenWidth() / 2), -camY + (self:getScreenHeight() / 2))
end

---@return love.Transform
function Camera:getCanvasToWorldTransform()
    return self:getWorldToCanvasTransform():inverse()
end

return Camera
