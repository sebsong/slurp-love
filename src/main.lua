require("engine/settings")
require("engine/color")
require("engine/tilemap")
require("engine/camera")

require("game/boat")
require("game/package")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ScreenScale = math.min(windowWidth / BaseCanvasWidth, windowHeight / BaseCanvasHeight)

	-- if ScreenScale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- ScreenScale = math.floor(ScreenScale)
	-- end

	local canvasWidth = BaseCanvasWidth * ScreenScale
	local canvasHeight = BaseCanvasHeight * ScreenScale
	Canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	CanvasToScreenTransform = love.math.newTransform(
		(windowWidth - canvasWidth) / 2,
		(windowHeight - canvasHeight) / 2,
		0
	)

	Camera = NewCamera()

	ColorPalette = LoadColorPalette("assets/art/look-of-horror.hex")

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		NewTileset("assets/art/tileset.png", 16),
		NewTileset("assets/art/packages.png", 16),
		NewTileset("assets/art/buildings.png", 64),
	}
	Tilemap = NewTilemapLua("assets/tilemap/map.lua", tilesets)
	LandTileLayerIndex = 1
	PackageTileLayerIndex = 2
	BuildingTileLayerIndex = 3

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	Boat = NewBoat(EntitiesImage)

	local packagesTileset = tilesets[PackageTileLayerIndex]
	Packages = {}
	for _, object in ipairs(Tilemap.layers[PackageTileLayerIndex].objects) do
		table.insert(Packages, NewPackage(Tilemap, packagesTileset, object))
	end

	local buildingTileset = tilesets[BuildingTileLayerIndex]
	Buildings = {}
	for _, object in ipairs(Tilemap.layers[BuildingTileLayerIndex].objects) do
		local objColIdx, objRowIdx = object.transform:transformPoint(0, 0)
		local colIdx, rowIdx = Tilemap.tilemapIndexToWorldTransform:transformPoint(objColIdx, objRowIdx)
		local tileId = object.tileId
		table.insert(Buildings, {
			tileId = tileId,
			image = buildingTileset.image,
			quad = buildingTileset.quads[tileId],
			transform = love.math.newTransform(colIdx, rowIdx),
		})
	end

	IsCameraPanning = false
	CameraPanSpeed = 0.5
	CameraZoomSpeed = 1.1

	Bgm = love.audio.newSource("assets/sound/bgm.ogg", "stream")
	Bgm:setVolume(0.2)
	Bgm:setLooping(true)
	Bgm:play()

	love.graphics.setPointSize(5)
	love.graphics.setBackgroundColor(0, 0, 0)
end

local function toggleCameraPan()
	IsCameraPanning = not IsCameraPanning
	love.mouse.setRelativeMode(IsCameraPanning)

	if not IsCameraPanning then
		Camera:resetZoom()
	end
end

function love.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not Boat:pickupPackages(Packages) then
			Boat:dropOffPackage()
		end
	end

	if key == "return" and not isRepeat then
		Camera:toggleZoom()
	end

	if key == "`" and not isRepeat then
		toggleCameraPan()
	end
end

function love.mousepressed(x, y, button, isTouch, presses)
	if button == 3 then
		toggleCameraPan()
	end
end

function love.mousemoved(x, y, dx, dy, isTouch)
	if IsCameraPanning then
		Camera.transform:translate(dx * CameraPanSpeed, dy * CameraPanSpeed)
	end
end

function love.wheelmoved(x, y)
	if IsCameraPanning and y ~= 0 then
		local cameraZoomMultiplier = CameraZoomSpeed
		if y < 0 then
			cameraZoomMultiplier = 1 / cameraZoomMultiplier
		end
		Camera.zoom = Camera.zoom * cameraZoomMultiplier
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	Boat:update(dt)

	if not IsCameraPanning then
		local boatX, boatY = Boat.transform:transformPoint(0, 0)
		Camera.transform:setTransformation(boatX, boatY)
	end
end

function love.draw()
	Canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(ScreenScale, ScreenScale)

			love.graphics.draw(BackgroundImage)

			love.graphics.scale(Camera.zoom, Camera.zoom)
			love.graphics.applyTransform(GetWorldToCanvasTransform(Camera))

			Tilemap:draw(LandTileLayerIndex, Camera)

			Boat:draw()

			for _, package in ipairs(Packages) do
				if Boat:indexOfPackage(package) then
					goto continue
				end

				love.graphics.push()
				love.graphics.applyTransform(package.transform)
				local _, _, width, height = package.quad:getViewport()
				love.graphics.draw(package.image, package.quad, -width / 2, -height)
				love.graphics.pop()
				::continue::
			end

			for _, building in ipairs(Buildings) do
				love.graphics.push()
				love.graphics.applyTransform(building.transform)
				local _, _, width, height = building.quad:getViewport()
				love.graphics.draw(building.image, building.quad, -width / 2, -height)
				love.graphics.pop()
			end

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
