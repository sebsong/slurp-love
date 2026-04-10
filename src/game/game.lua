local game = {}

local settings = require("engine/settings")
local color = require("engine/color")
local tilemap = require("engine/tilemap")
local camera = require("engine/camera")
local draw = require("engine/draw")
local collision = require("engine/collision")

local boat = require("game/boat")
local package = require("game/package")
local ui = require("game/ui")
local music = require("game/music")


function game.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ScreenScale = math.min(windowWidth / settings.baseCanvasWidth, windowHeight / settings.baseCanvasHeight)

	-- if ScreenScale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- ScreenScale = math.floor(ScreenScale)
	-- end

	local canvasWidth = settings.baseCanvasWidth * ScreenScale
	local canvasHeight = settings.baseCanvasHeight * ScreenScale
	Canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	CanvasToScreenTransform = love.math.newTransform(
		(windowWidth - canvasWidth) / 2,
		(windowHeight - canvasHeight) / 2,
		0
	)

	Camera = camera.new()

	color.loadPalette("assets/art/retrotronic-dx.hex")
	draw.loadShader(color.palette)

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	LandTileLayerIndex = 1
	ObjectTileLayerIndex = 2

	LandTilesetIndex = 1
	PackageTilesetIndex = 2
	BuildingTilesetIndex = 3
	MailboxTilesetIndex = 4
	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		tilemap.newTileset("assets/art/tileset.png", 16, 16),
		tilemap.newTileset("assets/art/packages.png", 16, 16),
		tilemap.newTileset("assets/art/buildings.png", 64, 64),
		tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	game.tilemap = tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")

	WorldObjects = {}

	Boat = boat.new(EntitiesImage, game.tilemap)
	table.insert(WorldObjects, Boat)

	for rowIdx, row in ipairs(game.tilemap.layers[LandTileLayerIndex].tiles) do
		for colIdx, tile in ipairs(row) do
			if tile.tileId then
				collision.register({ position = { colIdx, rowIdx }, collider = { width = 1, height = 1 } })
			end
		end
	end

	Packages = {}
	Mailboxes = {}
	for _, object in ipairs(game.tilemap.layers[ObjectTileLayerIndex].objects) do
		local tilesetIndex = object.tilesetIndex
		if (tilesetIndex == PackageTilesetIndex) then
			table.insert(Packages, package.toPackage(object))
		elseif (tilesetIndex == MailboxTilesetIndex) then
			table.insert(Mailboxes, object)
		end

		table.insert(WorldObjects, object)
	end

	ui:load()
	music:load()

	love.graphics.setPointSize(8)
	love.graphics.setLineWidth(.1)
	love.graphics.setBackgroundColor(0, 0, 0)

	LanternLightImage = love.graphics.newImage("assets/art/lantern_light.png")
	LanternShader     = love.graphics.newShader("assets/shader/lantern.glsl")
	LanternShader:send("canvasDimensions", { canvasWidth, canvasHeight })
	LanternShader:send("colorPalette", unpack(color.palette))
	LanternShader:send("colorMapping", unpack({ 1, 2, 3, 4, 5, 6, 7, 6 }))
end

function game.unload()
end

function game.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not Boat:pickupPackages(Packages) then
			Boat:deliverPackage(Mailboxes)
		end
	end

	Camera:keypressed(key, scancode, isRepeat)
end

function game.mousepressed(x, y, button, isTouch, presses)
	Camera:mousepressed(x, y, button, isTouch, presses)
end

function game.mousemoved(x, y, dx, dy, isTouch)
	Camera:mousemoved(x, y, dx, dy, isTouch)
end

function game.wheelmoved(x, y)
	Camera:wheelmoved(x, y)
end

function game.update(dt)
	Boat:update(dt)
	for _, package in ipairs(Boat.packages) do
		package:update(dt)
	end
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

function game.draw()
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
			love.graphics.applyTransform(camera.getWorldToCanvasTransform(Camera))

			game.tilemap:draw(LandTileLayerIndex, Camera)
			for _, worldObject in ipairs(WorldObjects) do
				draw.draw(worldObject)
			end

			if Boat.isLanternActive then
				local boatX, boatY = Boat.transform:transformPoint(0, 0)
				local lanternWidth, lanternHeight = LanternLightImage:getDimensions()
				love.graphics.setShader(LanternShader)
				LanternShader:send("canvasImage", Canvas)
				love.graphics.draw(LanternLightImage, boatX - lanternWidth / 2, boatY - lanternHeight / 2)
				love.graphics.setShader()
			end

			love.graphics.push()
			love.graphics.applyTransform(game.tilemap.tilemapIndexToWorldTransform)
			local boatColIdx, boatRowIdx = game.tilemap.worldToTilemapIndexTransform:transformPoint(Boat.transform
				:transformPoint(0, 0))
			-- collision.drawCollider(Boat.collider, { boatColIdx, boatRowIdx })
			love.graphics.pop()
			-- collision.drawTileColliders(Tilemap, LandTileLayerIndex)

			love.graphics.pop()

			ui:draw(Boat.packages)

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end

return game
