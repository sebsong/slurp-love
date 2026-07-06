local camera = {}
local meta = {}
meta.__index = meta

local settings = require("engine/settings")

function camera.new()
	local zoomToggles = { 1, 0.5 }
	local newCamera = {
		transform = love.math.newTransform(),

		screenWidth = settings.canvasPixelWidth,
		screenHeight = settings.canvasPixelHeight,
		isPanning = false,
		panSpeed = 0.5,
		zoom = zoomToggles[1],
		zoomToggleIdx = 1,
		zoomToggles = zoomToggles,
		zoomSpeed = 1.1,
	}
	setmetatable(newCamera, meta)

	return newCamera
end

function meta.getScreenWidth(self)
	return self.screenWidth / self.zoom
end

function meta.getScreenHeight(self)
	return self.screenHeight / self.zoom
end

function meta.toggleZoom(self)
	self.zoomToggleIdx = math.max((self.zoomToggleIdx + 1) % (#self.zoomToggles + 1), 1)
	self.zoom = self.zoomToggles[self.zoomToggleIdx]
end

function meta.resetZoom(self)
	self.zoom = self.zoomToggles[self.zoomToggleIdx]
end

function meta.togglePan(self)
	self.isPanning = not self.isPanning
	love.mouse.setRelativeMode(self.isPanning)

	if not self.isPanning then
		self:resetZoom()
	end
end

function meta.keypressed(self, key, scancode, isRepeat)
	if key == "return" and not isRepeat then
		self:toggleZoom()
	end

	if key == "`" and not isRepeat then
		self:togglePan()
	end
end

function meta.mousepressed(self, x, y, button, isTouch, presses)
	if button == 3 then
		self:togglePan()
	end
end

function meta.mousemoved(self, x, y, dx, dy, isTouch)
	if self.isPanning then
		self.transform:translate(dx * self.panSpeed, dy * self.panSpeed)
	end
end

function meta.wheelmoved(self, x, y)
	if self.isPanning and y ~= 0 then
		local cameraZoomMultiplier = self.zoomSpeed
		if y < 0 then
			cameraZoomMultiplier = 1 / cameraZoomMultiplier
		end
		self.zoom = self.zoom * cameraZoomMultiplier
	end
end

function meta.update(self, dt)
end

function camera.getWorldToCanvasTransform(_camera)
	local camX, camY = _camera.transform:transformPoint(0, 0)
	return love.math.newTransform(
		-camX + (_camera:getScreenWidth() / 2),
		-camY + (_camera:getScreenHeight() / 2)
	)
end

function camera.getCanvasToWorldTransform(_camera)
	return camera.getWorldToCanvasTransform(_camera):inverse()
end

return camera
