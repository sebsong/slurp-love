local game = {}

local canvas = require("engine/canvas")
local color = require("engine/color")
local tilemap = require("engine/tilemap")
local camera = require("engine/camera")
local draw = require("engine/draw")
local collision = require("engine/collision")
local scene = require("engine/scene")

local ui = require("game/ui")
local music = require("game/music")
local boat = require("game/boat")
local package = require("game/package")

local DAY_TO_LAYER_NAME = {
	"objects_1",
	"objects_2",
	"objects_3",
	"objects_4",
}

local LAND_LAYER_NAME = "base"
local OBJECT_LAYER_NAME = "objects_1"
local DECORATION_LAYER_NAME = "decorations"

local LAND_TILESET_NAME = "tileset"
local PACKAGE_TILESET_NAME = "packages"
local BUILDING_TILESET_NAME = "buildings"
local MAILBOX_TILESET_NAME = "mailboxes"

local boatObj

local worldObjects = {}
local packages = {}
local mailboxes = {}

local lanternLightImage
local lanternShader

function game.load()
	color.loadPalette("assets/art/retrotronic-dx.hex")
	draw.loadShader(color.palette)

	OBJECT_LAYER_NAME = DAY_TO_LAYER_NAME[scene.scenes.dayTracker.currentDay] or OBJECT_LAYER_NAME

	Camera = camera.new()

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		tilemap.newTileset("assets/art/tileset.png", 16, 16),
		tilemap.newTileset("assets/art/packages.png", 16, 16),
		tilemap.newTileset("assets/art/buildings.png", 64, 64),
		tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	game.tilemap = tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)

	worldObjects = {}
	packages = {}
	mailboxes = {}

	boatObj = boat.new(game.tilemap)
	table.insert(worldObjects, boatObj)

	for rowIdx, row in ipairs(game.tilemap.layers[LAND_LAYER_NAME].tiles) do
		for colIdx, tile in ipairs(row) do
			if tile.tileId then
				collision.register({ position = { colIdx, rowIdx }, collider = { width = 1, height = 1 } })
			end
		end
	end

	for _, object in ipairs(game.tilemap.layers[OBJECT_LAYER_NAME].objects) do
		local tilesetIndex = object.tilesetIndex
		if (tilesetIndex == PACKAGE_TILESET_NAME) then
			table.insert(packages, package.toPackage(object))
		elseif (tilesetIndex == MAILBOX_TILESET_NAME) then
			table.insert(mailboxes, object)
		end

		table.insert(worldObjects, object)
	end

	for _, object in ipairs(game.tilemap.layers[DECORATION_LAYER_NAME].objects) do
		table.insert(worldObjects, object)
	end

	ui:load()
	music:load()

	lanternLightImage = love.graphics.newImage("assets/art/lantern_light.png")
	lanternShader     = love.graphics.newShader("assets/shader/lantern.glsl")
	lanternShader:send("canvasDimensions", { canvas.canvas:getPixelWidth(), canvas.canvas:getPixelHeight() })
	lanternShader:send("colorPalette", unpack(color.palette))
	lanternShader:send("colorMapping", unpack({ 1, 2, 3, 4, 5, 6, 7, 6 }))
end

function game.unload()
	music:unload()
	collision.clearAll()
end

function game.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not boatObj:pickupPackages(packages) then
			boatObj:deliverPackage(mailboxes)
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
	boatObj:update(dt)
	for _, package in ipairs(boatObj.packages) do
		package:update(dt)
	end
	Camera:update(boatObj, dt)
	music:update(boatObj, dt)

	-- TODO: intersect world objects with what the camera can see and only sort + draw those
	table.sort(
		worldObjects,
		function(d1, d2)
			local _, d1Y = d1.transform:transformPoint(0, 0)
			local _, d2Y = d2.transform:transformPoint(0, 0)
			return d1Y < d2Y
		end
	)
end

function game.draw()
	love.graphics.draw(BackgroundImage)

	love.graphics.push()
	love.graphics.scale(Camera.zoom, Camera.zoom)
	love.graphics.applyTransform(camera.getWorldToCanvasTransform(Camera))

	game.tilemap:draw(LAND_LAYER_NAME, Camera)
	for _, worldObject in ipairs(worldObjects) do
		draw.draw(worldObject.drawComponent, worldObject.transform)
	end

	if boatObj.isLanternActive then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		local lanternWidth, lanternHeight = lanternLightImage:getDimensions()
		love.graphics.setShader(lanternShader)
		lanternShader:send("canvasImage", canvas.canvas)
		love.graphics.draw(lanternLightImage, boatX - lanternWidth / 2, boatY - lanternHeight / 2)
		love.graphics.setShader()
	end

	love.graphics.push()
	love.graphics.applyTransform(game.tilemap.tilemapIndexToWorldTransform)
	local boatColIdx, boatRowIdx = game.tilemap.worldToTilemapIndexTransform:transformPoint(boatObj.transform
		:transformPoint(0, 0))
	-- collision.drawCollider(Boat.collider, { boatColIdx, boatRowIdx })
	love.graphics.pop()
	-- collision.drawTileColliders(Tilemap, LandTileLayerIndex)

	love.graphics.pop()

	ui:draw(boatObj.packages)
end

function game.finishDay()
	scene.transition(scene.scenes.game, scene.scenes.dayTracker)
end

return game
