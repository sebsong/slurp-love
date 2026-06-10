local game = {}

local color = require("engine/color")
local tilemap = require("engine/tilemap")
local camera = require("engine/camera")
local draw = require("engine/draw")
local scene = require("engine/scene")
local slurp_math = require("engine/math")
local vec2 = require("engine/vec2")

local ui = require("game/ui")
local music = require("game/music")
local boat = require("game/boat")
local package = require("game/package")
local waterEffect = require("game/water_effect")
local tileEffect = require("game/tile_effect")
local floatingTileEffect = require("game/floating_tile_effect")
local lanternEffect = require("game/lantern_effect")
local packageEffect = require("game/package_effect")

local DAY_TO_LAYER_NAME = {
	"objects_monday",
	"objects_tuesday",
	"objects_wednesday",
	"objects_thursday",
	"objects_friday",
}

local LAND_LAYER_NAME = "base"
local OBJECT_LAYER_NAME = "objects_monday"
local BUILDINGS_LAYER_NAME = "buildings"

local LAND_TILESET_NAME = "tileset"
local PACKAGES_TILESET_NAME = "packages"
local BUILDINGS_TILESET_NAME = "buildings"
local MAILBOX_TILESET_NAME = "mailboxes"
local WALLS_TILESET_NAME = "walls"

local FLOATING_TILE_ID = 2
local LANTERN_REVEAL_TILE_ID = 3

local tilemapWorldRows
local tilemapFloatingWorldRows
local tilemapWallsSpriteBatch
local tilemapBuildingsSpriteBatch

local tilemapObj
local cameraObj
local boatObj

local worldEntities
local worldObjects
local packages
local mailboxes

local waterImage

local lanternLightImage
local lanternXRadius
local lanternYRadius

function game.load()
	color.loadPalette("assets/art/retrotronic-dx.hex")
	package.load()

	cameraObj = camera.new()

	OBJECT_LAYER_NAME = DAY_TO_LAYER_NAME[scene.scenes.dayTracker.currentDay] or OBJECT_LAYER_NAME

	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		tilemap.newTileset("assets/art/tileset.png", 16, 16),
		tilemap.newTileset("assets/art/packages.png", 16, 16),
		tilemap.newTileset("assets/art/buildings.png", 64, 64),
		tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	tilemapObj = tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)

	worldObjects = {}
	packages = {}
	mailboxes = {}

	boatObj = boat.new(tilemapObj)
	table.insert(worldObjects, boatObj)

	waterImage = love.graphics.newImage("assets/art/water.png")
	waterEffect.load(cameraObj, boatObj, love.timer.getTime())

	tileEffect.load(cameraObj, boatObj)
	floatingTileEffect.load()

	lanternLightImage                        = love.graphics.newImage("assets/art/lantern_light.png")
	local lanternXDiameter, lanternYDiameter = lanternLightImage:getDimensions()
	lanternXRadius, lanternYRadius           = lanternXDiameter / 2, lanternYDiameter / 2
	lanternEffect.load()

	packageEffect.load()

	local spriteBatchSize = math.max(tilemapObj.width, tilemapObj.height)
	tilemapWallsSpriteBatch = love.graphics.newSpriteBatch(tilesets[5].image, spriteBatchSize * 4, "static")
	tilemapWorldRows = {}
	tilemapFloatingWorldRows = {}
	for _, row in ipairs(tilemapObj.layers[LAND_LAYER_NAME].tiles) do
		for _, tile in ipairs(row) do
			if not tile.tileId then
				goto continue
			end

			local tileset = tilesets[tile.tilesetIndex]
			local tileImage = tileset.image
			local tileQuad = tileset.quads[tile.tileId]
			local _, _, width, height = tileQuad:getViewport()
			local x, y = tilemapObj.tilemapIndexToWorldTransform:transformPoint(tile.position.x, tile.position.y)

			if tile.tilesetName == WALLS_TILESET_NAME then
				tilemapWallsSpriteBatch:add(
					tileQuad,
					x - width / 2,
					y - height + tilemapObj.tileHeight / 2
				)
				goto continue
			end

			if tile.tilesetName == LAND_TILESET_NAME and tile.tileId == LANTERN_REVEAL_TILE_ID then
				local tileObj = {
					transform = love.math.newTransform(x, y),
					drawComponent = {
						shouldDraw = true,
						image = tileImage,
						quad = tileQuad,
						xOffset = -width / 2,
						yOffset = -height + tilemapObj.tileHeight / 2,
						zIndex = tile.zIndex,
						setShader = nil
					},
					isLanternRevealTile = true
				}
				tileObj.drawComponent.setShader = function()
					tileEffect.setShader(tileObj, boatObj, lanternXRadius, lanternYRadius)
				end
				table.insert(worldObjects, tileObj)
				goto continue
			end

			if tile.tilesetName == LAND_TILESET_NAME and tile.tileId == FLOATING_TILE_ID then
				local tilemapWorldRow = tilemapFloatingWorldRows[tile.worldRowIdx]
				if not tilemapWorldRow then
					tilemapWorldRow = {
						transform = love.math.newTransform(0, y),
						drawComponent = {
							shouldDraw = true,
							spriteBatch = love.graphics.newSpriteBatch(tileImage, spriteBatchSize, "static"),
							quad = tileQuad,
							zIndex = tile.zIndex,
							setShader = nil,
						},
						isLanternRevealTile = false
					}
					tilemapWorldRow.drawComponent.setShader = function()
						floatingTileEffect.setShader(tilemapWorldRow)
					end
					tilemapFloatingWorldRows[tile.worldRowIdx] = tilemapWorldRow
				end
				tilemapWorldRow.drawComponent.spriteBatch:add(
					tileQuad,
					x - width / 2,
					-height + tilemapObj.tileHeight / 2
				)
				goto continue
			end

			local tilemapWorldRow = tilemapWorldRows[tile.worldRowIdx]
			if not tilemapWorldRow then
				tilemapWorldRow = {
					transform = love.math.newTransform(0, y),
					drawComponent = {
						shouldDraw = true,
						spriteBatch = love.graphics.newSpriteBatch(tileImage, spriteBatchSize, "static"),
						quad = tileQuad,
						zIndex = tile.zIndex,
						setShader = nil,
					},
					isLanternRevealTile = false
				}
				tilemapWorldRow.drawComponent.setShader = function()
					tileEffect.setShader(tilemapWorldRow, boatObj, lanternXRadius, lanternYRadius)
				end
				tilemapWorldRows[tile.worldRowIdx] = tilemapWorldRow
			end
			tilemapWorldRow.drawComponent.spriteBatch:add(
				tileQuad,
				x - width / 2,
				-height + tilemapObj.tileHeight / 2
			)
			::continue::
		end
	end

	for _, object in ipairs(tilemapObj.layers[OBJECT_LAYER_NAME].objects) do
		local tilesetName = object.tilesetName
		if (tilesetName == PACKAGES_TILESET_NAME) then
			local package = package.toPackage(object)
			table.insert(packages, package)
			object.drawComponent.setShader = function()
				packageEffect.setShader(boatObj, packages, package)
			end
		elseif (tilesetName == MAILBOX_TILESET_NAME) then
			table.insert(mailboxes, object)
		end

		table.insert(worldObjects, object)
	end

	tilemapBuildingsSpriteBatch = love.graphics.newSpriteBatch(tilesets[3].image, 200, "static")
	for _, object in ipairs(tilemapObj.layers[BUILDINGS_LAYER_NAME].objects) do
		local x, y = object.transform:transformPoint(0, 0)
		tilemapBuildingsSpriteBatch:add(
			object.drawComponent.quad,
			x + object.drawComponent.xOffset,
			y + object.drawComponent.yOffset
		)
	end

	ui:load()
	music:load()
end

function game.unload()
	music:unload()
	love.audio.stop()
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
		if not boatObj:pickupPackage(packages) then
			local didDeliver = boatObj:deliverPackage(mailboxes)
			if didDeliver then
				evaluateWinCondition()
			end
		end
	end

	if key == "t" and not isRepeat then
		waterEffect.load(cameraObj, boatObj, love.timer.getTime())
	end

	if key == "r" and not isRepeat then
		scene.restart(game)
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
	boatObj:update(cameraObj, dt)
	for _, package in ipairs(boatObj.packages) do
		package:update(dt)
	end

	if not cameraObj.isPanning then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		cameraObj.transform:setTransformation(boatX, boatY)
	end

	music:update(boatObj, dt)

	local cameraX, cameraY = cameraObj.transform:transformPoint(0, 0)
	local cameraHalfHeight = cameraObj:getScreenHeight() / 2
	local startY, endY = cameraY - cameraHalfHeight, cameraY + cameraHalfHeight

	local startColIdx, startRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(cameraX, startY)
	local endColIdx, endRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(cameraX, endY)
	startColIdx = math.floor(startColIdx)
	startRowIdx = math.floor(startRowIdx)
	endColIdx = math.ceil(endColIdx)
	endRowIdx = math.ceil(endRowIdx)

	local startWorldRowIdx = tilemap.getWorldRowIdx(startColIdx, startRowIdx)
	local endWorldRowIdx = tilemap.getWorldRowIdx(endColIdx, endRowIdx) + 2

	worldEntities = {}
	for worldRowIdx = startWorldRowIdx, endWorldRowIdx do
		local worldRow = tilemapWorldRows[worldRowIdx]
		if worldRow then
			table.insert(worldEntities, worldRow)
		end
		local floatingWorldRow = tilemapFloatingWorldRows[worldRowIdx]
		if floatingWorldRow then
			table.insert(worldEntities, floatingWorldRow)
		end
	end
	for _, worldObject in ipairs(worldObjects) do
		local zIndex = worldObject.drawComponent.zIndex
		if slurp_math.inRange(zIndex, startWorldRowIdx, endWorldRowIdx) then
			table.insert(worldEntities, worldObject)
		end
	end

	table.sort(
		worldEntities,
		function(entity, otherEntity)
			return entity.drawComponent.zIndex < otherEntity.drawComponent.zIndex
		end
	)

	waterEffect.update(cameraObj, boatObj)
	tileEffect.update(cameraObj, boatObj)
	floatingTileEffect.update(cameraObj)
	lanternEffect.update(cameraObj)
	packageEffect.update()
end

function game.draw()
	waterEffect.setShader()
	love.graphics.draw(waterImage)
	love.graphics.setShader()

	love.graphics.push()
	love.graphics.scale(cameraObj.zoom, cameraObj.zoom)
	love.graphics.applyTransform(camera.getWorldToCanvasTransform(cameraObj))

	love.graphics.draw(tilemapWallsSpriteBatch)
	for _, worldObject in ipairs(worldEntities) do
		draw.draw(worldObject.drawComponent, worldObject.transform)
	end
	love.graphics.setShader()
	love.graphics.draw(tilemapBuildingsSpriteBatch)

	if boatObj.isLanternActive then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		lanternEffect.setShader()
		love.graphics.draw(lanternLightImage, boatX - lanternXRadius, boatY - lanternYRadius)
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
