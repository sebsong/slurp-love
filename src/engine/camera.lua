require("engine/settings")

function GetWorldToCanvasTransform(camera)
	local camX, camY = camera.transform:transformPoint(0, 0)
	return love.math.newTransform(
		-camX + (camera:getScreenWidth() / 2),
		-camY + (camera:getScreenHeight() / 2)
	)
end

function NewCamera()
	local screenWidth = BaseCanvasWidth
	local screenHeight = BaseCanvasHeight
	local zoomToggleIdx = 1
	local zoomToggles = { 1, 0.5 }

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

	return {
		transform = love.math.newTransform(),
		zoom = zoomToggles[1],

		getScreenWidth = getScreenWidth,
		getScreenHeight = getScreenHeight,
		toggleZoom = toggleZoom,
		resetZoom = resetZoom,
	}
end
