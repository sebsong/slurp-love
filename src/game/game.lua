local game = {}

local canvas = require("engine/canvas")
local color = require("engine/color")
local tilemap = require("engine/tilemap")
local camera = require("engine/camera")
local draw = require("engine/draw")
local collision = require("engine/collision")
local scene = require("engine/scene")
local vec2 = require("engine/vec2")
local set = require("engine/set")

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

local tilemapSpriteBatch
-- represents tilemap rows in world space (i.e. diagonal rows)
local tilemapWorldRows

local tilemapObj
local cameraObj
local boatObj

local worldObjects
local packages
local mailboxes

local lanternLightImage
local lanternShader

function game.load()
	color.loadPalette("assets/art/retrotronic-dx.hex")
	draw.loadShader(color.palette)

	OBJECT_LAYER_NAME = DAY_TO_LAYER_NAME[scene.scenes.dayTracker.currentDay] or OBJECT_LAYER_NAME

	cameraObj = camera.new()

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		tilemap.newTileset("assets/art/tileset.png", 16, 16),
		tilemap.newTileset("assets/art/packages.png", 16, 16),
		tilemap.newTileset("assets/art/buildings.png", 64, 64),
		tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	tilemapObj = tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)
	tilemapSpriteBatch = love.graphics.newSpriteBatch(tilesets[1].image, 3000, "static")

	worldObjects = {}
	packages = {}
	mailboxes = {}

	boatObj = boat.new(tilemapObj)
	table.insert(worldObjects, boatObj)

	local spriteBatchSize = math.max(tilemapObj.width, tilemapObj.height)
	tilemapWorldRows = {}
	for _, row in ipairs(tilemapObj.layers[LAND_LAYER_NAME].tiles) do
		for _, tile in ipairs(row) do
			if not tile.tileId then
				goto continue
			end

			local x, y = tilemapObj.tilemapIndexToWorldTransform:transformPoint(tile.position.x, tile.position.y)
			local tilemapWorldRow = tilemapWorldRows[tile.worldRowIdx]
			if not tilemapWorldRow then
				tilemapWorldRow = {
					transform = love.math.newTransform(0, y),
					drawComponent = {
						shouldDraw = true,
						image = love.graphics.newSpriteBatch(tilesets[1].image, spriteBatchSize, "static"),
						zIndex = tile.zIndex
					},
				}
				tilemapWorldRows[tile.worldRowIdx] = tilemapWorldRow
				table.insert(worldObjects, tilemapWorldRow)
			end
			local tileQuad = tilesets[1].quads[tile.tileId]
			local _, _, width, height = tileQuad:getViewport()
			tilemapWorldRow.drawComponent.image:add(
				tileQuad,
				x - width / 2,
				-height + tilemapObj.tileHeight / 2
			)
			::continue::
		end
	end

	for _, object in ipairs(tilemapObj.layers[OBJECT_LAYER_NAME].objects) do
		local tilesetName = object.tilesetName
		if (tilesetName == PACKAGE_TILESET_NAME) then
			table.insert(packages, package.toPackage(object))
		elseif (tilesetName == MAILBOX_TILESET_NAME) then
			table.insert(mailboxes, object)
		end

		table.insert(worldObjects, object)
	end

	for _, object in ipairs(tilemapObj.layers[DECORATION_LAYER_NAME].objects) do
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
	-- collision.clearAll()
end

function game.endDay()
	scene.scenes.dayTracker.nextDay()
	scene.transition(scene.scenes.game, scene.scenes.dayTracker)
end

local function evaluateWinCondition()
	for _, package in ipairs(packages) do
		if not package.isDelivered then
			return
		end
	end

	game.endDay()
end

function game.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not boatObj:pickupPackages(packages) then
			local didDeliver = boatObj:deliverPackage(mailboxes)
			if didDeliver then
				evaluateWinCondition()
			end
		end
	end

	cameraObj:keypressed(key, scancode, isRepeat)
end

function game.mousepressed(x, y, button, isTouch, presses)
	cameraObj:mousepressed(x, y, button, isTouch, presses)
end

function game.mousemoved(x, y, dx, dy, isTouch)
	cameraObj:mousemoved(x, y, dx, dy, isTouch)
end

function game.wheelmoved(x, y)
	cameraObj:wheelmoved(x, y)
end

function game.update(dt)
	boatObj:update(dt)
	for _, package in ipairs(boatObj.packages) do
		package:update(dt)
	end

	if not cameraObj.isPanning then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		cameraObj.transform:setTransformation(boatX, boatY)
	end

	music:update(boatObj, dt)

	-- TODO: intersect world objects with what the camera can see and only sort + draw those
	-- for _, tile in ipairs(boatObj.neighborTiles) do
	-- 	table.insert(worldObjectsArray, tile)
	-- end

	-- TODO: batch tiles into vertical rows, sort and draw the rows relative to other world objects
	table.sort(
		worldObjects,
		function(obj, otherObj)
			return obj.drawComponent.zIndex < otherObj.drawComponent.zIndex
		end
	)
end

function game.draw()
	love.graphics.draw(BackgroundImage)

	love.graphics.push()
	love.graphics.scale(cameraObj.zoom, cameraObj.zoom)
	love.graphics.applyTransform(camera.getWorldToCanvasTransform(cameraObj))

	-- love.graphics.draw(tilemapSpriteBatch)
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

	love.graphics.pop()

	ui:draw(boatObj.packages)
end

function game.debugTeleportBoatToCanvasPoint(x, y)
	local canvasToWorldTransform = camera.getCanvasToWorldTransform(cameraObj)
	local targetWorldPoint = vec2.new(canvasToWorldTransform:transformPoint(x, y))
	boatObj.transform:setTransformation(targetWorldPoint.x, targetWorldPoint.y, boatObj.rotation)
end

return game
