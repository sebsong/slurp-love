require("engine/settings")
local screenWidth = TargetCanvasWidth
local screenHeight = TargetCanvasHeight

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

local camera = {
	transform = love.math.newTransform(),
	getScreenWidth = getScreenWidth,
	getScreenHeight = getScreenHeight,
	toggleZoom = toggleZoom,
	zoom = zoomToggles[1],
}

return camera
