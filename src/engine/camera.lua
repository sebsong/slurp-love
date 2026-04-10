require("engine/settings")

local camera = {}

function camera.getWorldToCanvasTransform(_camera)
	local camX, camY = _camera.transform:transformPoint(0, 0)
	return love.math.newTransform(
		-camX + (_camera:getScreenWidth() / 2),
		-camY + (_camera:getScreenHeight() / 2)
	)
end

function camera.new()
	local screenWidth = BaseCanvasWidth
	local screenHeight = BaseCanvasHeight
	local zoomToggleIdx = 1
	local zoomToggles = { 1, 0.5 }
	local panSpeed = 0.5
	local zoomSpeed = 1.1
	local isPanning = false

	local function getScreenWidth(self)
		return screenWidth / self.zoom
	end

	local function getScreenHeight(self)
		return screenHeight / self.zoom
	end

	local function toggleZoom(self)
		zoomToggleIdx = math.max((zoomToggleIdx + 1) % (#zoomToggles + 1), 1)
		self.zoom = zoomToggles[zoomToggleIdx]
	end

	local function resetZoom(self)
		self.zoom = zoomToggles[zoomToggleIdx]
	end

	local function togglePan(self)
		isPanning = not isPanning
		love.mouse.setRelativeMode(isPanning)

		if not isPanning then
			self:resetZoom()
		end
	end

	local function keypressed(self, key, scancode, isRepeat)
		if key == "return" and not isRepeat then
			self:toggleZoom()
		end

		if key == "`" and not isRepeat then
			self:togglePan()
		end
	end

	local function mousepressed(self, x, y, button, isTouch, presses)
		if button == 3 then
			self:togglePan()
		end
	end

	local function mousemoved(self, x, y, dx, dy, isTouch)
		if isPanning then
			self.transform:translate(dx * panSpeed, dy * panSpeed)
		end
	end

	local function wheelmoved(self, x, y)
		if isPanning and y ~= 0 then
			local cameraZoomMultiplier = zoomSpeed
			if y < 0 then
				cameraZoomMultiplier = 1 / cameraZoomMultiplier
			end
			self.zoom = self.zoom * cameraZoomMultiplier
		end
	end

	local function update(self, boat, dt)
		if not isPanning then
			local boatX, boatY = boat.transform:transformPoint(0, 0)
			self.transform:setTransformation(boatX, boatY)
		end
	end

	return {
		transform = love.math.newTransform(),
		zoom = zoomToggles[1],

		getScreenWidth = getScreenWidth,
		getScreenHeight = getScreenHeight,
		toggleZoom = toggleZoom,
		resetZoom = resetZoom,
		togglePan = togglePan,

		keypressed = keypressed,
		mousepressed = mousepressed,
		mousemoved = mousemoved,
		wheelmoved = wheelmoved,
		update = update,
	}
end

return camera
