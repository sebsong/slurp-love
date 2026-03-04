require("engine/settings")
require("engine/color")
require("engine/tilemap")
require("engine/camera")
require("engine/draw_utils")

require("game/boat")
require("game/package")
local ui = require("game/ui")
local music = require("game/music")

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

	local colorPalette = LoadColorPalette("assets/art/retrotronic-dx.hex")
	LoadShader(colorPalette)

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	LandTileLayerIndex = 1
	ObjectTileLayerIndex = 2

	LandTilesetIndex = 1
	PackageTilesetIndex = 2
	BuildingTilesetIndex = 3
	MailboxTilesetIndex = 4
	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		NewTileset("assets/art/tileset.png", 16, 16),
		NewTileset("assets/art/packages.png", 16, 16),
		NewTileset("assets/art/buildings.png", 64, 64),
		NewTileset("assets/art/mailboxes.png", 16, 16),
		NewTileset("assets/art/walls.png", 16, 256),
	}
	Tilemap = NewTilemapLua("assets/tilemap/map.lua", tilesets)

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")

	WorldObjects = {}

	Boat = NewBoat(EntitiesImage)
	table.insert(WorldObjects, Boat)

	Packages = {}
	Mailboxes = {}
	for _, object in ipairs(Tilemap.layers[ObjectTileLayerIndex].objects) do
		local tilesetIndex = object.tilesetIndex
		if (tilesetIndex == PackageTilesetIndex) then
			table.insert(Packages, ConvertToPackage(object))
		elseif (tilesetIndex == MailboxTilesetIndex) then
			table.insert(Mailboxes, object)
		end

		table.insert(WorldObjects, object)
	end

	ui:load()
	music:load()

	love.graphics.setPointSize(5)
	love.graphics.setBackgroundColor(0, 0, 0)

	LanternLightImage = love.graphics.newImage("assets/art/lantern_light.png")
	LanternShader     = love.graphics.newShader("assets/shader/lantern.glsl")
	LanternShader:send("canvasDimensions", { canvasWidth, canvasHeight })
	LanternShader:send("colorPalette", unpack(colorPalette))
	LanternShader:send("colorMapping", unpack({ 1, 2, 3, 4, 5, 6, 7, 6 }))
end

function love.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not Boat:pickupPackages(Packages) then
			Boat:deliverPackage(Mailboxes)
		end
	end

	Camera:keypressed(key, scancode, isRepeat)
end

function love.mousepressed(x, y, button, isTouch, presses)
	Camera:mousepressed(x, y, button, isTouch, presses)
end

function love.mousemoved(x, y, dx, dy, isTouch)
	Camera:mousemoved(x, y, dx, dy, isTouch)
end

function love.wheelmoved(x, y)
	Camera:wheelmoved(x, y)
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	Boat:update(dt)
	Camera:update(Boat, dt)
	music:update(Boat, dt)

	-- TODO: intersect world objects with what the camera can see and only sort + draw those
	table.sort(
		WorldObjects,
		function(d1, d2)
			local _, d1Y = d1.transform:transformPoint(0, 0)
			local _, d2Y = d2.transform:transformPoint(0, 0)
			return d1Y < d2Y
		end
	)
end

function love.draw()
	love.graphics.setCanvas(Canvas)

	love.graphics.setCanvas()
	Canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(ScreenScale, ScreenScale)

			love.graphics.draw(BackgroundImage)

			love.graphics.push()
			love.graphics.scale(Camera.zoom, Camera.zoom)
			love.graphics.applyTransform(GetWorldToCanvasTransform(Camera))

			Tilemap:draw(LandTileLayerIndex, Camera)

			for _, worldObject in ipairs(WorldObjects) do
				Draw(worldObject)
			end

			if Boat.isLanternActive then
				local boatX, boatY = Boat.transform:transformPoint(0, 0)
				local lanternWidth, lanternHeight = LanternLightImage:getDimensions()
				love.graphics.setShader(LanternShader)
				LanternShader:send("canvasImage", Canvas)
				love.graphics.draw(LanternLightImage, boatX - lanternWidth / 2, boatY - lanternHeight / 2)
				love.graphics.setShader()
			end

			love.graphics.pop()

			ui:draw(Boat.packages)

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
